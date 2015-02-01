require 'active_support/all'
require 'pundit'
module Locomotive
  class API < Grape::API

    helpers APIAuthenticationHelpers
    helpers Pundit

    content_type :xml, 'application/xml'
    content_type :json, 'application/json'

    format :json
    format :xml

    prefix 'v2'

    rescue_from Pundit::NotAuthorizedError do
      error_response(message: { 'error' => '401 Unauthorized' }, status: 401)
    end


    mount TranslationAPI
    mount TokenAPI


  end
end
