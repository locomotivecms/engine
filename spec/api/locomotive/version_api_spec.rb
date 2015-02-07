require 'spec_helper'

module Locomotive
  describe VersionAPI do
    include Rack::Test::Methods

    describe 'GET /locomotive/api_test/v2/version.json' do
      context 'JSON' do
        subject { parsed_response }

        it 'returns the current engine version' do
          get '/locomotive/api_test/v2/version.json'
          expect(subject).to eq({ "engine" => Locomotive::VERSION })
        end

      end
    end
    
  end
end
