require 'test_helper'

class AuthenticationTest < ActionController::TestCase
  include Devise::TestHelpers
  tests PagesController

  def setup
    @user = new_user
    @user.save
  end

  def sso_sign_in(user)
    @controller.instance_variable_set('@sso_session', { 'cas_username' => user.email })
  end

  def sso_sign_out
    @controller.instance_variable_set('@sso_session', nil)
  end

  test 'authenticated' do
    sign_in @user
    sso_sign_in @user

    get :index

    assert_response :success
  end

  test 'not at all authenticated' do
    sign_out @user
    sso_sign_out

    get :index

    assert_response :success
  end

  test 'not authenticated by sso' do
    sign_in @user
    sso_sign_out

    get :index

    assert_response :success
    assert !@controller.user_signed_in?
  end

  test 'not authenticated by client' do
    sign_out @user
    sso_sign_in @user

    get :index

    assert_redirected_to :sso
  end

  test 'diffrent authentication' do
    sign_out @user
    sso_sign_in new_user

    get :index

    assert_redirected_to :sso
  end
end
