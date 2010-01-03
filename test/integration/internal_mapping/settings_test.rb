require File.dirname(__FILE__) + '/../../test_internal_mapping_helper.rb'

class SettingsTest < ActiveSupport::TestCase

  must "account_mapping_mode :auto should resolve to :internal" do
    assert_equal :auto, User.account_mapping_mode
    assert_equal :internal, User.account_mapping_mode_used
  end 
 
end