require 'spec_helper'

module Locomotive
  describe TranslationAPI do
    include Rack::Test::Methods
    let!(:site) { create(:site, domains: %w{www.acme.com}) }
    let!(:translation) { create(:translation, site: site) }
    let!(:unscoped_translation) { create(:translation) }
    let!(:account) { create(:account) }
    let(:params) { { locale: :en } }

    let!(:membership) do
      create(:membership, account: account, site: site, role: 'admin')
    end

    subject { parsed_response }

    context 'no authenticated site' do
      describe "GET /locomotive/acme/api_test/v2/translations/index.json" do
        context 'JSON' do
          it 'returns unauthorized message' do
            get '/locomotive/acme/api_test/v2/translations/index.json'
            expect(subject).to eq({ 'error' => '401 Unauthorized' })
          end

          it 'returns unauthorized response' do
            get '/locomotive/acme/api_test/v2/translations/index.json'
            expect(last_response.status).to eq(401)
          end
        end
      end
    end


    context 'authenticated site' do
      before do
        header 'X-Locomotive-Account-Token', account.api_token
        header 'X-Locomotive-Account-Email', account.email
        header 'X-Locomotive-Site-Handle', site.handle
        #current_session.env('HTTP_HOST', site.domains.first)
      end

      describe "GET /locomotive/acme/api_test/v2/translations/index.json" do
        context 'JSON' do
          it 'returns a successful response' do
            get '/locomotive/acme/api_test/v2/translations/index.json'
            expect(last_response).to be_successful
          end

          it 'returns one translation' do
            get '/locomotive/acme/api_test/v2/translations/index.json'
            entity = entity_to_hash(TranslationEntity.new(translation))
            expect(subject).to include(entity)
          end
        end
      end
    end

  end
end
