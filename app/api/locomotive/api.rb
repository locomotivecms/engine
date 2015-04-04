require 'active_support/all'
require 'pundit'

require_relative 'api/entities'
require_relative 'api/resources'
require_relative 'api/forms'
require_relative 'api/middlewares'
require_relative 'api/helpers'
require_relative 'api/exception_rescuers'

module Locomotive
  module API

    def self.to_app
      Rack::Builder.new do
        use Locomotive::API::LoggerMiddleware
        run Locomotive::API::Dispatch
      end
    end

    class Dispatch < Grape::API

      helpers Pundit
      helpers API::AuthenticationHelper
      helpers API::ParamsHelper
      helpers API::PersistenceHelper

      include API::ExceptionRescuers

      content_type :xml, 'application/xml'
      content_type :json, 'application/json'

      format :xml
      format :json

      prefix 'v3'

      mount API::TokenResource
      mount API::AccountResource
      mount API::TranslationResource
      mount API::VersionResource
      mount API::ThemeAssetResource
      mount API::SiteResource
      mount API::SnippetResource
      mount API::PageResource
      mount API::MyAccountResource
      mount API::MembershipResource
      mount API::CurrentSiteResource

      route :any, '*path' do
        error!({ error: "Unrecognized request path: #{params[:path]}" }, 404)
      end

    end

  end
end
