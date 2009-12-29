class AddAuthlogicRpxMigrationGenerator < Rails::Generator::Base
  def manifest

    record do |m| 
      
      m.migration_template template_name, 'db/migrate', :assigns => {
        :user_model_base => user_model_base,
        :user_model => user_model,
        :user_model_collection => user_model_collection
      }
    end
  end
  
  def file_name
    "add_authlogic_rpx_migration"
  end
  
  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} #{spec.name} [options] [mapping:mapping_mode] [user_model:model_name]"
    end

    attr_writer :params
    def params
      @params ||= {"mapping" => "internal", "user_model" => "User"}.merge( Hash[*(@args.collect { |arg| arg.split(":") }.flatten)] )
    end
    
    def user_model_base
      params['user_model'].singularize.downcase
    end
    def user_model
      params['user_model'].singularize.capitalize
    end
    def user_model_collection
      params['user_model'].pluralize.downcase
    end
    def mapping
      params['mapping']
    end
    def template_name
      mapping == 'none' ? 'migration_no_mapping.rb' : 'migration_internal_mapping.rb'
    end
end
