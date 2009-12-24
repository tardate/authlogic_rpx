module AuthlogicRpx
	# This module is responsible for adding all of the RPX goodness to the Authlogic::Session::Base class.
	module Session
		# Add a simple rpx_identifier attribute and some validations for the field.
		def self.included(klass)
			klass.class_eval do
				extend Config
				include Methods
			end
		end
		
		module Config

			def find_by_rpx_identifier_method(value = nil)
				rw_config(:find_by_rpx_identifier_method, value, :find_by_rpx_identifier)
			end
			alias_method :find_by_rpx_identifier_method=, :find_by_rpx_identifier_method

			# Auto Register is enabled by default. 
			# Add this in your Session object if you need to disable auto-registration via rpx
			#
			def auto_register(value=true)
				auto_register_value(value)
			end
			def auto_register_value(value=nil)
				rw_config(:auto_register,value,true)
			end      
			alias_method :auto_register=,:auto_register

			# Add this in your Session object to set the RPX API key 
			# RPX won't work without the API key. Set it here if not already set in your app configuration.
			#
			def rpx_key(value=nil)
				rpx_key_value(value)
			end
			def rpx_key_value(value=nil)
				if !inheritable_attributes.include?(:rpx_key) 
					RPXNow.api_key = value 
				end
				rw_config(:rpx_key,value,false)
			end
			alias_method :rpx_key=,:rpx_key

			# Add this in your Session object to set whether RPX returns extended user info 
			# By default, it will not, which is enough to get username, name, email and the rpx identified
			# if you want to map additional information into your user details, you can request extended
			# attributes (though not all providers give them - see the RPX docs)
			#
			def rpx_extended_info(value=true)
				rpx_extended_info_value(value)
			end
			def rpx_extended_info_value(value=nil)
				rw_config(:rpx_extended_info,value,false)
			end
			alias_method :rpx_extended_info=,:rpx_extended_info

		end
		
		module Methods
		  
			def self.included(klass)
				klass.class_eval do
					attr_accessor :new_registration
					after_persisting :add_rpx_identifier, :if => :adding_rpx_identifier?
					validate :validate_by_rpx, :if => :authenticating_with_rpx?
				end
			end
      		  
			# Determines if the authenticated user is also a new registration.
			# For use in the session controller to help direct the most appropriate action to follow.
			# 
			def new_registration?
				new_registration
			end
			
			# Determines if the authenticated user has a complete registration (no validation errors)
			# For use in the session controller to help direct the most appropriate action to follow.
			# 
			def registration_complete?
				attempted_record && attempted_record.valid?
			end

		private
		  # Tests if current request is for RPX authentication
		  #
			def authenticating_with_rpx?
				controller.params[:token] && !controller.params[:add_rpx]
			end

			# hook instance finder method to class
			#
			def find_by_rpx_identifier_method
				self.class.find_by_rpx_identifier_method
			end

			# Tests if auto_registration is enabled (on by default)
			#
			def auto_register?
				self.class.auto_register_value
			end

			# Tests if rpx_extended_info is enabled (off by default)
			#
			def rpx_extended_info?
				self.class.rpx_extended_info_value
			end

      # Tests if current request is the special case of adding RPX to an existing account
      #
			def adding_rpx_identifier?
				controller.params[:token] && controller.params[:add_rpx]
			end
			
			# Handles the special case of RPX being added to an existing account. 
			# At this point, a session has been established as a result of a "save" on the user model (which indirectly triggers user session validation).
			# We do not directly add the RPX details to the user record here in order to avoid getting
			# into a recursive dance between the session and user models.
			# Rather, it uses the trick of adding the necessary RPX information to the session object, 
			# and the user model will pluck these values out before completing its validation step.
			#
			def add_rpx_identifier
				data = RPXNow.user_data(controller.params[:token], :extended=> rpx_extended_info? ) {|raw| raw }
				controller.session['added_rpx_data'] = data if data
			end
			
			# the main RPX magic. At this point, a session is being validated and we know RPX identifier
			# has been provided. We'll callback to RPX to verify the token, and authenticate the matching 
			# user. 
			# If no user is found, and we have auto_register enabled (default) this method will also 
			# create the user registration stub.
			#
			# On return to the controller, you can test for new_registration? and registration_complete?
			# to determine the most appropriate action
			#
			def validate_by_rpx
				@rpx_data = RPXNow.user_data(
					controller.params[:token],
					:extended => rpx_extended_info?) { |raw| raw }
				
				# If we don't have a valid sign-in, give-up at this point
				if @rpx_data.nil?
					errors.add_to_base("Authentication failed. Please try again.")
					return false
				end
				
				rpx_id = @rpx_data['profile']['identifier']
				if rpx_id.blank?
					errors.add_to_base("Authentication failed. Please try again.")
					return false
				end
				
				self.attempted_record = klass.send(find_by_rpx_identifier_method, rpx_id)
				
				# so what do we do if we can't find an existing user matching the RPX authentication...
				if !attempted_record
					if auto_register?
						self.attempted_record = klass.new()
						map_rpx_data
						
						# save the new user record - without session maintenance else we
						# get caught in a self-referential hell, since both session and
						# user objects invoke each other upon save
						self.new_registration = true
						self.attempted_record.creating_new_record_from_rpx = true
						self.attempted_record.rpx_identifiers.build(:identifier => rpx_id)
						self.attempted_record.save_without_session_maintenance
					else
						errors.add_to_base("We did not find any accounts with that login. Enter your details and create an account.")
						return false
					end
				else
					map_rpx_data_each_login
				end
			
			end

			# map_rpx_data maps additional fields from the RPX response into the user object during auto-registration.
			# Override this in your session model to change the field mapping
			# See https://rpxnow.com/docs#profile_data for the definition of available attributes
			#
			# In this procedure, you will be writing to fields of the "self.attempted_record" object, pulling data from the @rpx_data object.
			#
			# WARNING: if you are using auto-registration, any fields you map should NOT have constraints enforced at the database level.
			# authlogic_rpx will optimistically attempt to save the user record during registration, and 
			# violating a database constraint will cause the authentication/registration to fail.
			#
			# You can/should enforce any required validations at the model level e.g.
			#   validates_uniqueness_of   :username, :case_sensitive => false
			# This will allow the auto-registration to proceed, and the user can be given a chance to rectify the validation errors
			# on your user profile page.
			#
			# If it is not acceptable in your application to have user records created with potential validation errors in auto-populated fields, you
			# will need to override map_rpx_data and implement whatever special handling makes sense in your case. For example:
			#   - directly check for uniqueness and other validation requirements
			#   - automatically "uniquify" fields like username
			#   - save conflicting profile information to "pending user review" columns or a seperate table
			#
			def map_rpx_data
				self.attempted_record.send("#{klass.login_field}=", @rpx_data['profile']['preferredUsername'] ) if attempted_record.send(klass.login_field).blank?
				self.attempted_record.send("#{klass.email_field}=", @rpx_data['profile']['email'] ) if attempted_record.send(klass.email_field).blank?
			end

			# map_rpx_data_each_login provides a hook to allow you to map RPX profile information every time the user
			# logs in.
			# By default, nothing is mapped. 
			#
			# This would mainly be used to update relatively volatile information that you are maintaining in the user model (such as profile image url)
			#
			# In this procedure, you will be writing to fields of the "self.attempted_record" object, pulling data from the @rpx_data object.
			#
			#
			def map_rpx_data_each_login

			end
	
		end
		
	end
end