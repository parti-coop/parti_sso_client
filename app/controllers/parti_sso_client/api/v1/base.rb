require "grape"
require "rest_client"

module PartiSsoClient
  module API
    module V1
      class Base < Grape::API
        include PartiSsoClient::API::GlobalDefaults
        include PartiSsoClient::API::V1::Defaults

        desc "Authorize"
        params do
          requires :email, type: String
          requires :token, type: String
          requires :client, type: String
        end
        get "authorize" do
          user = User.find_by(email: permitted_params[:email])

          if user.nil?
            status 401
            return { error: 'invalid credentials' }
          end

          params = {
            email: permitted_params[:email],
            token: permitted_params[:token],
            client: permitted_params[:client],
            server: request.host
          }
          sso_response = RestClient.get uri_to_sso('/api/v1/certify', params)
          sso_certification = JSON.parse(sso_response.to_s)

          unless sso_certification.has_key?("error")
            api_key = user.api_keys.find_or_initialize_by(client: permitted_params[:client])
            api_key.generate_token
            api_key.set_last_access_date
            api_key.authentication_id = sso_certification["api_key_id"]
            api_key.expires_at = DateTime.parse(sso_certification["expires_at"])
            api_key.save!

            { user: user,
              token: api_key.token }
          else
            status 401
            { error: 'failed to certify',
              authentication: sso_certification["error"] }
          end
        end
      end
    end
  end
end
