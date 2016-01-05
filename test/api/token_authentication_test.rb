require 'test_helper'

class TokenAuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    @user = new_user
    @user.save

    @token = 'token'
    @client = 'uuid'
    @expires_at = 30.days.from_now
    @authentication_id = 100
  end

  def authorize
    RestClient.stubs(:get).returns({
      api_key_id: @authentication_id,
      expires_at: @expires_at,
      user_data: { username: @user.email} }.to_json)
    get "/users/api/v1/authorize?email=#{@user.email}&token=#{@token}&client=#{@client}"

    JSON.parse(response.body)["token"]
  end

  test 'authenticated' do
    authorization_token = authorize

    get '/api/v1/do_something', nil, authorization: %{Token token="#{authorization_token}";email="#{@user.email}";client="#{@client}"}
    result = JSON.parse(response.body)
    assert_equal @user.email, result["user"]["email"]
  end

  test 'unauthenticated' do
    authorization_token = authorize

    get '/api/v1/do_something', nil, authorization: %{Token token="#{authorization_token + 'xxx'}";email="#{@user.email}";client="#{@client}"}
    result = JSON.parse(response.body)
    assert_equal 'unauthenticated', result["error"]
  end
end
