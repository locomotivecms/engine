require 'active_support/all'
require 'pundit'

module Locomotive
  class DispatchAPI < Grape::API

    helpers Pundit
    helpers APIAuthenticationHelpers
    helpers APIParamsHelper
    helpers PersistenceHelper

    include APIExceptionRescuers

    content_type :xml, 'application/xml'
    content_type :json, 'application/json'

    format :xml
    format :json

    prefix 'v3'

    mount Resources::TokenAPI
    mount Resources::TranslationAPI
    mount Resources::VersionAPI
    mount Resources::ThemeAssetAPI
    mount Resources::SiteAPI
    mount Resources::SnippetAPI
    mount Resources::PageAPI
    mount Resources::MyAccountAPI
    mount Resources::MembershipAPI
    mount Resources::CurrentSiteAPI
    mount Resources::AccountAPI

    route :any, '*path' do
      error!({ error: "Unrecognized request path: #{params[:path]}" }, 404)
    end

  end

  API = Rack::Builder.new do
    use Locomotive::APILogger
    run Locomotive::DispatchAPI
  end
end
