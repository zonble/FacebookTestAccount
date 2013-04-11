# FacebookTestUser.rb
#
# Author: Weizhong Yang <zonble at gmail dot com>
#
# A tool which helps to create and delete test account for Facebook.
# See https://developers.facebook.com/docs/test_users/

require 'net/http'
require 'net/https'
require 'openssl'

require 'rubygems'
require 'json'

# The manager which helps to create and delete test accounts.
class FacebookTestUserManager

  def initialize(facebookAppID, facebookSecret)
    @appID = facebookAppID
    @appSecret = facebookSecret
    @appAccessToken = nil
  end

  private
  def hash_to_querystring(hash)
    hash.keys.inject('') do |query_string, key|
      query_string << '&' unless key == hash.keys.first
      query_string << "#{URI.encode(key.to_s)}=#{URI.escape(hash[key])}"
    end
  end

  def _open_uri(uri)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    return https.request_get(uri.path + '?' + uri.query)
  end

  def _obtain_app_access_token
    get_parameters = {
      :client_id => @appID,
      :client_secret => @appSecret,
      :grant_type => 'client_credentials'}
    uri = URI('https://graph.facebook.com/oauth/access_token' << '?' << hash_to_querystring(get_parameters))
    res = _open_uri(uri)
    @appAccessToken = res.body[('access_token='.length)..-1]
  end

  public

  # Create a new test account by giving a user name.
  # Params:
  # - user_name: name of the new test account.
  # - permissions: requested permissions.
  def create_test_account(user_name='test',
     permissions=['email', 'publish_stream', 'user_about_me', 'publish_actions'])

    if @appAccessToken.nil?
      _obtain_app_access_token
    end

    get_parameters = {
      :installed => 'true',
      :name => user_name,
      :locale => 'en_US',
      :method => 'post',
      :access_token => @appAccessToken,
      :permissions => permissions * ","}
    uri_str = 'https://graph.facebook.com/%s/accounts/test-users' % [@appID]
    uri_str << '?' << hash_to_querystring(get_parameters)
    res = _open_uri(URI(uri_str))
    return JSON.parse(res.body)
  end

  # Delete a test account.
  # Params:
  # - user_id: ID of the test user.
  def delete_test_user(user_id)

    if @appAccessToken.nil?
      _obtain_app_access_token
    end

    get_parameters = {
      :method => 'delete',
      :access_token => @appAccessToken}
    uri_str = 'https://graph.facebook.com/%s/' % [user_id]
    uri_str << '?' << hash_to_querystring(get_parameters)
    res = _open_uri(URI(uri_str))
    return res.body == 'true'
  end

  # List all test users.
  def list_test_users

    if @appAccessToken.nil?
      _obtain_app_access_token
    end

    get_parameters = { :access_token => @appAccessToken }
    uri_str = 'https://graph.facebook.com/%s/accounts/test-users' % [@appID]
    uri_str << '?' << hash_to_querystring(get_parameters)
    res = _open_uri(URI(uri_str))
    return JSON.parse(res.body)['data']
  end

  # Delete all test users.
  def delete_all_test_users

    if @appAccessToken.nil?
      _obtain_app_access_token
    end

    users = list_test_users()
    users.each do |user|
      delete_test_user(user['id'])
    end
  end

end


if __FILE__ == $0
  appID = '181603781919524'
  appSecret = 'f075c9b716d5b48d04d40275a92c7fc7'
  m = FacebookTestUserManager.new(appID, appSecret)
  user =  m.create_test_account('test')
  user_id = user['installed']
  access_token = user['access_token']
  p user
  m.delete_test_user(user_id)

  p m.list_test_users
  m.delete_all_test_users
  p m.list_test_users
end

