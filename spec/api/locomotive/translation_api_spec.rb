require 'spec_helper'

describe Locomotive::TranslationAPI do
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
    describe "GET /locomotive/api_test/v2/translations/index.json" do
      context 'JSON' do
        it 'returns unauthorized message' do
          get '/locomotive/api_test/v2/translations/index.json'
          expect(subject).to eq({ 'error' => '401 Unauthorized' })
        end

        it 'returns unauthorized response' do
          get '/locomotive/api_test/v2/translations/index.json'
          expect(last_response.status).to eq(401)
        end
      end
    end
  end

  context 'authenticated site' do

    before do
      current_session.env('locomotive.site', site)
      current_session.env('locomotive.locale', :en)
      header 'X-Locomotive-Account-Token', account.api_token
      header 'X-Locomotive-Account-Email', account.email
      current_session.env('HTTP_HOST', site.domains.first)
    end

    describe "GET /locomotive/api_test/v2/translations/index.json" do
      context 'JSON' do
        it 'returns a successful response' do
          get '/locomotive/api_test/v2/translations/index.json'

          expect(response).to be_success
        end

        it 'returns one translation' do
          get '/locomotive/api_test/v2/translations/index.json'
          expect(subject).to include('translation')
        end
      end
    end
  end

end
