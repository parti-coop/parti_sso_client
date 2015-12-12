module ActionDispatch::Routing
  class Mapper
    def sso_devise(options={})
      defaults = { skip: [:sessions],
        controllers: { cas_sessions: 'parti_sso_client/sessions' },
        class_name: 'PartiSsoClient::User',
        module: :devise }
      merged = options.merge(defaults)
      merged[:skip] << options[:skip]
      merged[:skip].compact!.uniq!
      merged[:controllers] = (options[:controllers] || {}).merge(defaults[:controllers])
      devise_for :users, merged
    end
  end
end
