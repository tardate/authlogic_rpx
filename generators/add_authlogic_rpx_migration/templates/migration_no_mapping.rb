class AddAuthlogicRpxMigration < ActiveRecord::Migration

  def self.up
    add_column :<%= user_model_collection %>, :rpx_identifier, :string
    add_index :<%= user_model_collection %>, :rpx_identifier
      
    # == Customisation may be required here ==
    # You may need to remove database constraints on other fields if they will be unused in the RPX case
    # (e.g. crypted_password and password_salt to make password authentication optional). 
    # If you are using auto-registration, you must also remove any database constraints for fields that will be automatically mapped
    # e.g.:
    #change_column :<%= user_model_collection %>, :crypted_password, :string, :default => nil, :null => true
    #change_column :<%= user_model_collection %>, :password_salt, :string, :default => nil, :null => true
    
  end

  def self.down
    remove_column :<%= user_model_collection %>, :rpx_identifier
    
    # == Customisation may be required here ==
    # Restore user model database constraints as appropriate
    # e.g.:
    #[:crypted_password, :password_salt].each do |field|
    #  <%= user_model %>.all(:conditions => "#{field} is NULL").each { |user| user.update_attribute(field, "") if user.send(field).nil? }
    #  change_column :<%= user_model_collection %>, field, :string, :default => "", :null => false
    #end

  end
end
