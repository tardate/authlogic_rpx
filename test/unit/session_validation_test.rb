require File.dirname(__FILE__) + '/../test_helper.rb'

class SessionValidationTest < ActiveSupport::TestCase

  must "unvalidated session creation fails" do
    session = UserSession.new
    assert_false session.save
  end 

  
  must "validate valid_rpx_auth_user_one" do
    session = UserSession.create(users(:valid_rpx_auth_user_one), true )
    assert_true session.valid?
  end 
 
end