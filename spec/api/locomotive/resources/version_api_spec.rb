require 'spec_helper'

module Locomotive
  module Resources
    describe VersionAPI do
      include Rack::Test::Methods

      describe 'GET /locomotive/api/v3/version.json' do
        context 'JSON' do
          subject { parsed_response }

          it 'returns the current engine version' do
            get '/locomotive/api/v3/version.json'
            expect(subject).to eq({ "engine" => Locomotive::VERSION })
          end

        end
      end

    end
  end
end
