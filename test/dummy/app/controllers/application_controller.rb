class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include PartiSsoClient::Authentication
  before_action -> { verify_authentication(sign_in_path) }

  private

  def sign_in_path
    Rails.env.test? ? sso_path : new_user_session_path
  end
end
