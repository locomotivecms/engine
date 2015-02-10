require 'spec_helper'

module Locomotive
  describe ThemeAssetAPI do
    include Rack::Test::Methods
    let!(:site) { create(:site, domains: %w{www.acme.com}) }

    let!(:account) { create(:account) }
    let!(:theme_asset) { create(:theme_asset, site: site, source: rack_upload) }

    let(:rack_upload) { Rack::Test::UploadedFile.new(path) }
    let(:path) { Rails.root.join('../../spec/fixtures/images/rails.png').to_s }

    let(:params) { { locale: :en } }
    let(:url_prefix) { '/locomotive/acmi/api_test/v2/theme_assets' }


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

      describe "GET /locomotive/acme/api_test/v2/theme_assets/index.json" do
        context 'JSON' do
          before { get "#{url_prefix}/index.json" }
          it 'returns a successful response' do

            expect(last_response).to be_successful
          end

        end
      end


    end

  end
end
