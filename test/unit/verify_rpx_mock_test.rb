require File.dirname(__FILE__) + '/../test_helper.rb'

class VerifyRpxMockTest < ActiveSupport::TestCase

  must "get a validated response from RPXNow" do
    rpx_data = RPXNow.user_data('valid_rpx_auth_user_one',:extended => true )
    assert_not_nil rpx_data
    assert_not_nil rpx_data[:identifier]
    rpx_id = rpx_data[:identifier]
		assert_false rpx_id.blank?								
  end

  must "get a validated response from RPXNow raw mode" do
    rpx_data = RPXNow.user_data('valid_rpx_auth_user_one',:extended => true ) { |raw| raw }
    assert_not_nil rpx_data
    assert_not_nil rpx_data['profile']
    rpx_id = rpx_data['profile']['identifier']
		assert_false rpx_id.blank?					
		rpx_provider_name = rpx_data['profile']['providerName']
		assert_false rpx_provider_name.blank?					
  end

  must "get nil response from RPXNow if invalid request" do
    rpx_data = RPXNow.user_data('invalid token',:extended => true )
    assert_nil rpx_data
  end


end