require File.dirname(__FILE__) + '/../../test_helper.rb'

class SettingsTest < ActiveSupport::TestCase

  must "account_mapping_mode :auto should resolve to :none" do
    assert_equal :auto, User.account_mapping_mode
    assert_equal :none, User.account_mapping_mode_used
  end 
 
end