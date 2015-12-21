module ActionDispatch::Routing
  class Mapper
    def sso_devise(options={})
      defaults = { skip: [:sessions],
        controllers: { cas_sessions: 'parti_sso_client/sessions' },
        class_name: 'User',
        module: :devise }
      merged = options.merge(defaults)
      merged[:skip] << options[:skip]
      merged[:skip].compact!.uniq!
      merged[:controllers] = (options[:controllers] || {}).merge(defaults[:controllers])
      devise_for :users, merged
      get "/sign_up", to: redirect { |params, request|
        query = {
          service: Rails.application.routes.url_helpers.user_service_url()
        }.to_query
        URI.join(Devise.cas_base_url, '/users/new', "?#{query}").to_s
      }
      get "/edit_user", to: redirect { |params, request|
        query = {
          service: Rails.application.routes.url_helpers.user_service_url(sync: true)
        }.to_query
        URI.join(Devise.cas_base_url, '/users/edit', "?#{query}").to_s
      }
    end
  end
end
