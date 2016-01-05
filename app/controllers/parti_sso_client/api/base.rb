require "grape"

module PartiSsoClient
  module API
    class Base < Grape::API
      mount PartiSsoClient::API::V1::Base
    end
  end
end
