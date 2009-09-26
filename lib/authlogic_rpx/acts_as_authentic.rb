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

		end
		
		module Methods
		
			# Set up some simple validations
			def self.included(klass)
				klass.class_eval do
					validates_uniqueness_of :rpx_identifier, :scope => validations_scope, :if => :using_rpx?
					validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_with_rpx?)
					validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_with_rpx?)
					validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_with_rpx?)
					before_validation :adding_rpx_identifier
					after_create :map_rpx_identifier
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
				!rpx_identifier.blank?
			end

			# test if account it using normal password authentication
			def using_password?
				!send(crypted_password_field).blank?
			end

		private
			
			def validate_password_with_rpx?
				!using_rpx? && require_password?
			end
			
			def adding_rpx_identifier
				return true unless session_class && session_class.controller
				new_rpx_id = session_class.controller.session['added_rpx_identifier']	
				unless new_rpx_id.blank?
					session_class.controller.session['added_rpx_identifier'] = nil		
					self.rpx_identifier = new_rpx_id 
				end
				return true
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