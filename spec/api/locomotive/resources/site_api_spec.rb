require 'spec_helper'

module Locomotive
  module Resources
    describe SiteAPI do
      include Rack::Test::Methods
      let!(:site) { create(:site, domains: %w{www.acme.com}) }

      let!(:account) { create(:account) }

      let(:params) { { locale: :en } }
      let(:url_prefix) { '/locomotive/acmi/api_test/v2/sites' }


      let!(:membership) do
        create(:admin, account: account, site: site, role: 'admin')
      end

      subject { parsed_response }

      context 'authenticated site' do
        before do
          header 'X-Locomotive-Account-Token', account.api_token
          header 'X-Locomotive-Account-Email', account.email
          header 'X-Locomotive-Site-Handle', site.handle
        end

        describe 'GET index' do
          context 'JSON' do
            before { get "#{url_prefix}/index.json" }
            it 'returns a successful response' do

              expect(last_response).to be_successful
            end

          end
        end

        describe 'GET show' do
          context 'JSON' do
            before { get "#{url_prefix}/#{site.id}.json"}

            it 'returns a successful response' do
              expect(last_response).to be_successful
            end
          end
        end


      end

    end
  end
end
