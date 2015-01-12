module Locomotive
  class API < Grape::API

    content_type :xml, 'application/xml'
    content_type :json, 'application/json'

    format :json
    format :xml

    prefix 'v2'

    before do
      #authenticate_locomotive_account!
    end

    mount TranslationAPI

  end
end
