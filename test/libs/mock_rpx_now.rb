require File.dirname(__FILE__) + '/rpxresponse.rb'

module RPXNow

  def self.user_data(token, options={})
    data = get_test_data(token)
    if block_given? then yield(data) else parse_user_data(data) end
  end

  def self.parse_user_data(data)
    data
  end
  
  def self.get_test_data(token)
    response = Rpxresponse.find_by_username('valid_rpx_auth_user_one')
    
    data = {}
    data['profile'] = {}
    data['profile']['identifier'] = response.identifier
    data['profile']['providerName'] = response.provider_name
    
    data[:identifier] = data['profile']['identifier']
    data[:providerName] = data['profile']['providerName']
    data[:email] = response.verified_email
    data[:username] = response.username
    data[:name] = response.display_name
    
    data
  end
end