require File.dirname(__FILE__) + '/../test_helper.rb'

class SessionSettingsTest < ActiveSupport::TestCase

  must "RPX API key is set" do
    assert UserSession.rpx_key, "the RPX API key must be set in the Authlogic::Session class configuration"
  end
 
  must "auto_register default is enabled" do
    assert_true UserSession.auto_register_value
  end 
  
  must "auto_register set disabled" do
    UserSession.auto_register false
    assert_false UserSession.auto_register_value
  end
  
  must "auto_register set enabled" do
    UserSession.auto_register true
    assert_true UserSession.auto_register_value
  end 

  must "rpx_extended_info default is disbled" do
    assert_false UserSession.rpx_extended_info_value
  end 

  must "rpx_extended_info set enabled" do
    UserSession.rpx_extended_info true
    assert_true UserSession.rpx_extended_info_value
  end 

  must "rpx_extended_info set disabled" do
    UserSession.rpx_extended_info false
    assert_false UserSession.rpx_extended_info_value
  end 

end