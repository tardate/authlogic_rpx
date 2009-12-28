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


			# account_merge_enabled is used to enable merging of accounts.
			#
			# * <tt>Default:</tt> false
			# * <tt>Accepts:</tt> boolean
			def account_merge_enabled(value=false)
				account_merge_enabled_value(value)
			end
			def account_merge_enabled_value(value=nil)
				rw_config(:account_merge_enabled,value,false)
			end      
			alias_method :account_merge_enabled=,:account_merge_enabled
			
			
						
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
				  identifier.user
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
					attr_writer :creating_new_record_from_rpx
				end

				RPXIdentifier.class_eval do
					belongs_to klass.name.downcase.to_sym
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

			# determines if account merging is enabled
			def account_merge_enabled?
				self.class.account_merge_enabled_value
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
  				rpx_id = added_rpx_data['profile']['identifier']
  				rpx_provider_name	= added_rpx_data['profile']['providerName']
					unless self.rpx_identifiers.find_by_identifier( rpx_id )
					  # identifier not already set for this user
					  another_user = self.class.find_by_rpx_identifier( rpx_id )
					  if another_user
					    return false unless account_merge_enabled?
					    # another user already has this id registered
					    # merge all IDs from another_user to self, with application callbacks before/after
					    before_merge_rpx_data( another_user, self )
				      self.rpx_identifiers << another_user.rpx_identifiers
				      after_merge_rpx_data( another_user, self )
					  else
					    self.rpx_identifiers.create( :identifier => rpx_id, :provider_name => rpx_provider_name )
					  end
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
			# This method is called just before authlogic_rpx merges the user registration for 'from_user' into 'to_user'
			# Authlogic_RPX is responsible for merging registration data.
			#
			# By default, it does not merge any other details (e.g. application data ownership)
			#
			def before_merge_rpx_data( from_user, to_user )
			
			end
			
			# after_merge_rpx_data provides a hook for application developers to perform account clean-up after authlogic_rpx has
			# migrated registration details.
			#
			# By default, does nothing. It could, for example, be used to delete or disable the 'from_user' account
			#
			def after_merge_rpx_data( from_user, to_user )
			
			end
											    
			
		end
	end
end