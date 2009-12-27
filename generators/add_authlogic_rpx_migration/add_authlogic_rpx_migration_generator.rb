class AddAuthlogicRpxMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m| 
      m.migration_template 'migration.rb', 'db/migrate'
    end
  end
  
  def file_name
    "add_authlogic_rpx_migration"
  end
end
