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

  	class GeneralError < StandardError
  	end
  	class ConfigurationError < StandardError
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
			
			# account_mapping_mode is used to explicitly set/override the mapping behaviour.
			#
			# * <tt>Default:</tt> :auto
			# * <tt>Accepts:</tt> :auto, :none, :internal, :rpxnow
			def account_mapping_mode(value=:auto)
				account_mapping_mode_value(value)
			end
			def account_mapping_mode_value(value=nil)
			  raise AuthlogicRpx::ActsAsAuthentic::ConfigurationError.new unless value.nil? || [:auto,:none,:internal].include?( value ) 
				rw_config(:account_mapping_mode,value,:auto)
			end      
			alias_method :account_mapping_mode=,:account_mapping_mode
			
			# returns the actual account mapping mode in use - resolves :auto to actual mechanism
			#
			attr_writer :account_mapping_mode_used
			def account_mapping_mode_used
			  @account_mapping_mode_used ||= (
			    account_mapping_mode_value == :auto ?
			    ( RPXIdentifier.table_exists? ? 
			      :internal : 
			      ( self.column_names.include?("rpx_identifier") ? :none : AuthlogicRpx::ActsAsAuthentic::ConfigurationError.new ) 
			    ) :
			    account_mapping_mode_value
			  )
			end


			# determines if no account mapping is supported (the only behaviour in authlogic_rpx v1.0.4)
			def using_no_mapping?
				account_mapping_mode_used == :none
			end
			# determines if internal account mapping is enabled (behaviour added in authlogic_rpx v1.1.0)
			def using_internal_mapping?
				account_mapping_mode_used == :internal
			end		
			# determines if rpxnow account mapping is enabled (currently not implemented)
			def using_rpx_mapping?
				account_mapping_mode_used == :rpxnow
			end
			
		end
		
		module Methods
		
			# Mix-in the required methods based on mapping mode
			#
			def self.included(klass)
				klass.class_eval do
				  
				  case
				  when using_no_mapping?
				    include AuthlogicRpx::MethodSet_NoMapping
				    
          when using_internal_mapping? 
            include AuthlogicRpx::MethodSet_InternalMapping
            has_many :rpx_identifiers, :class_name => 'RPXIdentifier', :dependent => :destroy
            
        		# Add custom find_by_rpx_identifier class method
        		#
        		def self.find_by_rpx_identifier(id)
        			identifier = RPXIdentifier.find_by_identifier(id)
        			if identifier.nil?
        			  if self.column_names.include? 'rpx_identifier'
        			    # check for authentication using <=1.0.4, migrate identifier to rpx_identifiers table
        			    user = self.find( :first, :conditions => [ "rpx_identifier = ?", id ] )
        			    unless user.nil?
        			      user.add_rpx_identifier( id, 'Unknown' )
        			    end
        			    return user
        			  else
        			    return nil
        			  end
        			else
        			  identifier.user
        			end
        		end
			            
          else
            raise AuthlogicRpx::ActsAsAuthentic::ConfigurationError.new( "invalid or unsupported account_mapping_mode" )
          end

          # Set up some fundamental conditional validations
					validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_not_rpx?)
					validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_not_rpx?)
					validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_not_rpx?)
					
					before_validation :adding_rpx_identifier
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
			
			# test if account it using normal password authentication
			def using_password?
				!send(crypted_password_field).blank?
			end

			
		private
			
			# tests if password authentication should be checked instead of rpx (i.e. if rpx is enabled but not used by this user) 
			def validate_password_not_rpx?
				!using_rpx? && require_password?
			end

			# determines if account merging is enabled; delegates to class method
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
  				
					unless self.identified_by?( rpx_id )
					  # identifier not already set for this user..
					  
					  another_user = self.class.find_by_rpx_identifier( rpx_id )
					  if another_user
					    return false unless account_merge_enabled?
					    # another user already has this id registered..
					    
					    # merge all IDs from another_user to self, with application callbacks before/after
					    before_merge_rpx_data( another_user, self )
				      merge_user_id another_user
				      after_merge_rpx_data( another_user, self )
				      
					  else
					    self.add_rpx_identifier( rpx_id, rpx_provider_name )
					  end
				  end
				  
					map_added_rpx_data( added_rpx_data ) 
				end
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
	
	# Mix-in collection of methods that are specific to no-mapping mode of operation
	#
	module MethodSet_NoMapping
		# test if account it using RPX authentication
		# 
		def using_rpx?
		  !rpx_identifier.blank?
		end
		
    # adds RPX identification to the instance.
    # Abstracts how the RPX identifier is added to allow for multiplicity of underlying implementations
		# 
    def add_rpx_identifier( rpx_id, rpx_provider_name )
		  self.rpx_identifier = rpx_id
		  #TODO: make rpx_provider_name a std param?
    end
    
    # Checks if given identifier is an identity for this account
    # 
		def identified_by?( id )
			self.rpx_identifier == id
		end

		# merge_user_id is an internal method used to merge the actual RPX identifiers
		# 
		def merge_user_id( from_user )
		  self.rpx_identifier = from_user.rpx_identifier
		  from_user.rpx_identifier = nil
		  from_user.save
		  from_user.reload		
		end

    # Uses default find_by_rpx_identifier class method
    
    # Add an rpx_identifier collection method
    def rpx_identifiers
      [{ :identifier => rpx_identifier, :provider_name => "Unknown" }]
    end
	end
	
	
	# Mix-in collection of methods that are specific to internal mapping mode of operation
	#
	module MethodSet_InternalMapping
		# test if account it using RPX authentication
		# 
		def using_rpx?
		  !rpx_identifiers.empty?
		end	

    # adds RPX identification to the instance.
    # Abstracts how the RPX identifier is added to allow for multiplicity of underlying implementations
		# 
    def add_rpx_identifier( rpx_id, rpx_provider_name )
		  self.rpx_identifiers.build(:identifier => rpx_id, :provider_name => rpx_provider_name )
    end

    # Checks if given identifier is an identity for this account
    # 
		def identified_by?( id )
			self.rpx_identifiers.find_by_identifier( id )
		end
		
		# merge_user_id is an internal method used to merge the actual RPX identifiers
		# 
		def merge_user_id( from_user )
			self.rpx_identifiers << from_user.rpx_identifiers	
			from_user.reload
		end
		

	end
	
end