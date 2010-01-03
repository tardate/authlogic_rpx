require "rubygems"
begin
  gem 'test-unit'
  require "test/unit"
  require File.dirname(__FILE__) + "/libs/ext_test_unit"
rescue Gem::LoadError
  # assume using stdlib Test:Unit
  require "test/unit"
  require File.dirname(__FILE__) + "/libs/ext_test_unit"
end

require "ruby-debug"
require "active_record"
require "action_controller"

ActiveRecord::Schema.verbose = false

begin
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
rescue ArgumentError
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
end

ActiveRecord::Base.configurations = true
ActiveRecord::Schema.define(:version => 1) do

  create_table :rpxresponses do |t|
    t.string    :identifier
    t.string    :provider_name
    t.string    :username
    t.string    :verified_email
    t.string    :display_name
  end
    
  create_table :users do |t|
    t.datetime  :created_at
    t.datetime  :updated_at
    t.integer   :lock_version, :default => 0
    t.string    :login
    t.string    :crypted_password
    t.string    :password_salt
    t.string    :persistence_token
    t.string    :single_access_token
    t.string    :perishable_token
    t.string    :rpx_identifier
    t.string    :email
    t.string    :first_name
    t.string    :last_name
    t.integer   :login_count, :default => 0, :null => false
    t.integer   :failed_login_count, :default => 0, :null => false
    t.datetime  :last_request_at
    t.datetime  :current_login_at
    t.datetime  :last_login_at
    t.string    :current_login_ip
    t.string    :last_login_ip
  end

end

require "active_record/fixtures"
require "authlogic"
require "authlogic/test_case"

require "rpx_now"
RPX_API_KEY = 'abcdefghijklmnopqrstuvwxyz' unless defined? RPX_API_KEY

require File.dirname(__FILE__) + "/../lib/authlogic_rpx"

require File.dirname(__FILE__) + "/libs/rails_trickery"
require File.dirname(__FILE__) + '/libs/rpxresponse'
require File.dirname(__FILE__) + '/libs/mock_rpx_now'
require File.dirname(__FILE__) + '/libs/user'
require File.dirname(__FILE__) + '/libs/user_session'

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.fixture_path = File.dirname(__FILE__) + "/fixtures"
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = false
  fixtures :all
  setup :activate_authlogic
  
  private

    
end