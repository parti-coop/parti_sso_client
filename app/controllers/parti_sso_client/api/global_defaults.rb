require "grape"
require "grape-active_model_serializers"

module PartiSsoClient
  module API
    module GlobalDefaults
      extend ActiveSupport::Concern

      included do
        prefix "api"
        default_format :json
        format :json
        formatter :json, Grape::Formatter::ActiveModelSerializers

        helpers do
          def permitted_params
            @permitted_params ||= declared(params,
               include_missing: false)
          end

          def logger
            Rails.logger
          end

          def uri_to_sso(path, params)
            "#{URI.join(Devise.cas_base_url, path)}?#{params.to_query}"
          end
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error_response(message: e.message, status: 422)
        end
      end
    end
  end
end
