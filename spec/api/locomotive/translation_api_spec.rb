require 'spec_helper'

describe Locomotive::TranslationAPI do
  describe "GET /locomotive/api_test/v2/translation/index" do
    context 'JSON' do
      it 'returns an empty array' do
        get '/locomotive/api_test/v2/translation/index.json'
        expect(parsed_response).to eq []
      end
    end
  end
  
  def parsed_response
    JSON.parse(response.body)
  end
  
end
