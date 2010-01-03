require File.dirname(__FILE__) + '/../test_helper.rb'

class ActsAsAuthenticSettingsTest < ActiveSupport::TestCase


 
  must "account_merge_enabled default is disabled" do
    assert_false User.account_merge_enabled_value
  end 
  
  must "account_merge_enabled set disabled" do
    User.account_merge_enabled false
    assert_false User.account_merge_enabled_value
  end
  
  must "account_merge_enabled set enabled" do
    User.account_merge_enabled true
    assert_true User.account_merge_enabled_value
  end 

  must "account_mapping_mode default is :auto" do
    assert_equal :auto, User.account_mapping_mode_value
    assert_equal :none, User.account_mapping_mode_used
  end 

  must "account_mapping_mode set :none" do
    User.account_mapping_mode :none
    assert_equal :none, User.account_mapping_mode_value
    assert_equal :none, User.account_mapping_mode_used
  end 

  must "account_mapping_mode set :internal" do
    User.account_mapping_mode :internal
    assert_equal :internal, User.account_mapping_mode_value
    assert_equal :none, User.account_mapping_mode_used
  end

  must "invalid account_mapping_mode raises config error" do
    assert_raises( AuthlogicRpx::ActsAsAuthentic::ConfigurationError ) do
      User.account_mapping_mode :invalid
    end
  end
 
end