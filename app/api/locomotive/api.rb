module Locomotive
  class API < Grape::API
    
    content_type :xml, 'application/xml'
    content_type :json, 'application/json'
    
    format :json
    format :xml    
    
    prefix 'v2'
    mount TranslationAPI
    
  end
end