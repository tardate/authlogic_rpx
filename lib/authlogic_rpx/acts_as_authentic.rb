# This module is responsible for adding RPX functionality to Authlogic. Checkout the README for more info and please
# see the sub modules for detailed documentation.
module AuthlogicRpx
	# This module is responsible for adding in the RPX functionality to your models. It hooks itself into the
	# acts_as_authentic method provided by Authlogic.
	module ActsAsAuthentic
		# Adds in the neccesary modules for acts_as_authentic to include and also disabled password validation if
		# RPX is being used.
		def self.included(klass)
			klass.class_eval do
				extend Config
				add_acts_as_authentic_module(Methods, :prepend)
			end
		end

		module Config
		
			# map_id is used to enable RPX identity mapping
			# experimental - a feature of RPX paid accounts and not properly developed/tested yet
			#
			# * <tt>Default:</tt> false
			# * <tt>Accepts:</tt> boolean
			def map_id(value = false)
				rw_config(:map_id, value, false)
			end
			alias_method :map_id=, :map_id
			
			# Name of this method is defined in find_by_rpx_identifier_method
			# method in session.rb
			def find_by_rpx_identifier(id)
				identifier = RPXIdentifier.find_by_identifier(id)
				if identifier.nil?
				  if self.column_names.include? 'rpx_identifier'
				    # check for authentication using <=1.0.4, migrate identifier to rpx_identifiers table
				    user = self.find( :first, :conditions => [ "rpx_identifier = ?", id ] )
				    unless user.nil?
				      user.rpx_identifiers.create( :identifier => id )
				    end
				    return user
				  else
				    return nil
				  end
				else
				  self.find( identifier.user_id )
				end
			end
			
		end
		
		module Methods
		
			# Set up some simple validations
			def self.included(klass)
				klass.class_eval do
					has_many :rpx_identifiers, :class_name => 'RPXIdentifier', :dependent => :destroy

					validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_with_rpx?)
					validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_with_rpx?)
					validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_with_rpx?)
					before_validation :adding_rpx_identifier
					after_create :map_rpx_identifier
					attr_writer :creating_new_record_from_rpx
				end
			end

			# support a block given to the save
			def save(perform_validation = true, &block)
				result = super perform_validation
				yield(result) if block_given?
				result
			end

			# test if account it using RPX authentication
			def using_rpx?
				!rpx_identifiers.empty?
			end

			# test if account it using normal password authentication
			def using_password?
				!send(crypted_password_field).blank?
			end

		private
			
			def validate_password_with_rpx?
				if @creating_new_record_from_rpx
					false
				else
					!using_rpx? && require_password?
				end
			end
			
			# hook for adding RPX identifier to an existing account. This is invoked prior to model validation.
			# RPX information is plucked from the controller session object (where it was placed by the session model as a result
			# of the RPX callback)
			# The minimal action taken is to add an RPXIdentifier object to the user.
			#
			# This procedure chains to the map_added_rpx_data, which may be over-ridden in your project to perform
			# additional mapping of RPX information to the user model as may be desired.
			#
			def adding_rpx_identifier
				return true unless session_class && session_class.controller
				added_rpx_data = session_class.controller.session['added_rpx_data']	
				unless added_rpx_data.blank?
					session_class.controller.session['added_rpx_data'] = nil
					unless self.rpx_identifiers.find_by_identifier( added_rpx_data['profile']['identifier'] )
					    self.rpx_identifiers.create( :identifier => added_rpx_data['profile']['identifier'], :provider_name => added_rpx_data['profile']['providerName'] )
				  end
					map_added_rpx_data( added_rpx_data ) 
				end
				return true
			end
			
			# map_added_rpx_data maps additional fields from the RPX response into the user object during the "add RPX to existing account" process.
			# Override this in your user model to perform field mapping as may be desired
			# See https://rpxnow.com/docs#profile_data for the definition of available attributes
			#
			# "self" at this point is the user model. Map details as appropriate from the rpx_data structure provided.
			#
			def map_added_rpx_data( rpx_data )

			end
			
			# before_merge_rpx_data provides a hook for application developers to perform data migration prior to the merging of user accounts.
			# This method is called just before authlogic_rpx merges theuser registration for 'from_user' into 'to_user'
			# Authlogic_RPX is responsible for merging registration data.
			#
			# By default, it does not merge any other details (e.g. application data ownership)
			#
			def before_merge_rpx_data( from_user, to_user )
			
			end
			
			# experimental - a feature of RPX paid accounts and not properly developed/tested yet
			def map_id?
				self.class.map_id
			end
				
			# experimental - a feature of RPX paid accounts and not properly developed/tested yet
			def map_rpx_identifier
				RPXNow.map(rpx_identifier, id) if using_rpx? && map_id?
			end
			
			# experimental - a feature of RPX paid accounts and not properly developed/tested yet
			def unmap_rpx_identifer
				RPXNow.unmap(rpx_identifier, id) if using_rpx? && map_id?
			end
			
		end
	end
end