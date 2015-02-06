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
      create(:admin, account: account, site: site, role: 'admin')
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
      end

      describe "GET /locomotive/acme/api_test/v2/translations/index.json" do
        context 'JSON' do
          before { get '/locomotive/acme/api_test/v2/translations/index.json' }
          it 'returns a successful response' do
            expect(last_response).to be_successful
          end

          it 'returns one translation' do
            entity = entity_to_hash(TranslationEntity.new(translation))
            expect(subject).to include(entity)
          end
        end
      end

      describe "GET /locomotive/acme/api_test/v2/translations/[id].json" do
        context 'JSON' do
          before { get "/locomotive/acme/api_test/v2/translations/#{translation.id}.json" }
          it 'returns a successful response' do
            expect(last_response).to be_successful
          end
        end
      end

      describe "POST /locomotive/acme/api_test/v2/translations.json" do
        context 'JSON' do
          let(:json) { { key: :site, values: { one: :uno } } }

          it 'creates a translation on the current site' do
            expect{ post("/locomotive/acmi/api_test/v2/translations.json", translation: json) }.to change{ Locomotive::Translation.count }.by(1)
          end
        end
      end
    end

  end
end
