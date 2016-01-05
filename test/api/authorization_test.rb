require 'test_helper'
require 'rest-client'

class AuthorizationTest < ActionDispatch::IntegrationTest
  def setup
    @user = new_user
    @user.save
    @token = 'token'
    @client = 'uuid'
    @expires_at = 30.days.from_now
    @authentication_id = 100
  end

  test "authorize" do
    refute @user.api_keys.exists?(client: @client)

    RestClient.stubs(:get).returns({
      api_key_id: @authentication_id,
      expires_at: @expires_at,
      user_data: { username: @user.email} }.to_json)
    get "/users/api/v1/authorize?email=#{@user.email}&token=#{@token}&client=#{@client}"

    result = JSON.parse(@response.body)
    token = result['token']

    api_key = @user.api_keys.find_by(client: @client)
    refute api_key.nil?
    assert api_key.authenticated?(token)
    assert_in_delta @expires_at, api_key.expires_at, 1.second
    assert_equal @authentication_id, api_key.authentication_id
  end

  test "already existed api_key" do
    RestClient.stubs(:get).returns({
      api_key_id: @authentication_id,
      expires_at: @expires_at,
      user_data: { username: @user.email} }.to_json)
    get "/users/api/v1/authorize?email=#{@user.email}&token=#{@token}&client=#{@client}"

    assert @user.api_keys.exists?(client: @client)
    result = JSON.parse(@response.body)
    previous_token = result['token']

    new_authentication_id = @authentication_id + 200
    new_expires_at = @expires_at + 30.days
    RestClient.stubs(:get).returns({
      api_key_id: new_authentication_id,
      expires_at: new_expires_at,
      user_data: { username: @user.email} }.to_json)
    get "/users/api/v1/authorize?email=#{@user.email}&token=#{@token}&client=#{@client}"

    result = JSON.parse(@response.body)
    token = result['token']

    api_key = @user.api_keys.find_by(client: @client)
    refute api_key.nil?
    refute_equal previous_token, token
    assert api_key.authenticated?(token)
    assert_in_delta new_expires_at, api_key.expires_at, 1.second
    assert_equal new_authentication_id, api_key.authentication_id
  end

  test 'failed to certify' do
    refute @user.api_keys.exists?(client: @client)

    RestClient.stubs(:get).returns({
      error: 'uncertified' }.to_json)
    get "/users/api/v1/authorize?email=#{@user.email}&token=#{@token}&client=#{@client}"

    refute @user.api_keys.exists?(client: @client)
    result = JSON.parse(@response.body)
    assert_equal "failed to certify", result["error"]
    assert_equal "uncertified", result["authentication"]
    assert_equal 401, @response.status
  end

  test 'not found user' do
    not_found_email = 'not_found@email.com'
    refute User.exists?(email: not_found_email)

    get "/users/api/v1/authorize?email=#{not_found_email}&token=#{@token}&client=#{@client}"

    result = JSON.parse(@response.body)
    assert_equal "invalid credentials", result["error"]
    assert_equal 401, @response.status
  end
end
