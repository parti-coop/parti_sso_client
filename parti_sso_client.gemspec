$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "parti_sso_client/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "parti_sso_client"
  s.version     = PartiSsoClient::VERSION
  s.authors     = ["dali"]
  s.email       = ["dali@ufofactory.org"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of PartiSsoClient."
  s.description = "TODO: Description of PartiSsoClient."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"
  s.add_dependency "devise", "~> 3.5.2"
  s.add_dependency "devise_cas_authenticatable", "~> 1.6.0"

  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "jquery-rails", "~> 4.0.5"
end
