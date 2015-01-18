require 'active_support/all'
module Locomotive
  class API < Grape::API

    helpers APIAuthenticationHelpers
    include Concerns::ExceptionController
    include Concerns::AuthorizationController
    include Concerns::SiteDispatcherController


    # Authentication needs email + token
    # 1. simple authentication pattern
    # 2. write up a helper to manually look up token. https://mikecoutermarsh.com/rails-grape-api-key-authentication/
    content_type :xml, 'application/xml'
    content_type :json, 'application/json'

    format :json
    format :xml

    prefix 'v2'

    # every resource, expcet TokenAPI and AccountAPI needs email, token and site
    # config option to disable creating new accounts for a site.  Account is not scoped to site.
    # membership only created by admin of site
    mount TranslationAPI
    mount TokenAPI


  end
end
