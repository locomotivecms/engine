require 'active_support/all'
require 'pundit'

module Locomotive
  module API

    # FIX: reload! will work as expected in production
    module Middlewares; end
    module Entities; end

    def self.to_app
      Rack::Builder.new do
        use Locomotive::API::Middlewares::LocaleMiddleware
        use Locomotive::API::Middlewares::LoggerMiddleware
        use Locomotive::API::Middlewares::ParamsDecoderMiddleware
        run Locomotive::API::Dispatch
      end
    end

    class Dispatch < Grape::API

      helpers Pundit
      helpers API::Helpers::AuthenticationHelper
      helpers API::Helpers::ParamsHelper
      helpers API::Helpers::PersistenceHelper
      helpers API::Helpers::PaginationHelper
      helpers API::Helpers::LocalesHelper

      include API::ExceptionRescuers

      content_type :xml, 'application/xml'
      content_type :json, 'application/json'

      format :xml
      format :json

      prefix 'v3'

      mount API::Resources::TokenResource
      mount API::Resources::AccountResource
      mount API::Resources::TranslationResource
      mount API::Resources::VersionResource
      mount API::Resources::ThemeAssetResource
      mount API::Resources::SiteResource
      mount API::Resources::SnippetResource
      mount API::Resources::ContentTypeResource
      mount API::Resources::ContentEntryResource
      mount API::Resources::PageResource
      mount API::Resources::MyAccountResource
      mount API::Resources::MembershipResource
      mount API::Resources::CurrentSiteResource
      mount API::Resources::ContentAssetResource

      route :any, '*path' do
        error!({ error: "Unrecognized request path: #{params[:path]}" }, 404)
      end

    end

  end
end
