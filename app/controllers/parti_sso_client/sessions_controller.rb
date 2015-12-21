module PartiSsoClient
  class SessionsController < Devise::CasSessionsController
    include PartiSsoClient::Authentication

    # Skip redirect_to_sign_in to fix
    # flash message not showing up in Rails 4
    # (https://github.com/nbudin/devise_cas_authenticatable/issues/81)

    skip_before_filter :redirect_to_sign_in,
    only: [:new, :destroy, :single_sign_out, :service, :unregistered]

    # Skip verify_signed_out_user for Devise >= 3.3.0
    skip_before_filter :verify_signed_out_user

    def service
      resource = warden.authenticate!(:scope => resource_name)
      after_sign_in_path = after_sign_in_path_for(resource)

      if resource_name == :user and params[:sync].present? and params[:sync] == 'true'
        User.sync(resource.email)
      end

      redirect_to after_sign_in_path
    end

    def after_sign_in_path_for(resource)
      if (controller_name == 'sessions' and action_name == 'service')
        (session[SSO_RETURN_TO_KEY] || super(resource))
      else
        super(resource)
      end
    end
  end
end
