require 'spec_helper'

module Locomotive
  module Resources
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
            before { get "#{url_prefix}/#{theme_asset.id}.json"}

            it 'returns a successful response' do
              expect(last_response).to be_successful
            end
          end
        end

        describe 'POST create' do
          context 'JSON' do
            let(:theme_asset) do
              attributes_for(:theme_asset).tap do |attributes|
                attributes[:source] = Rack::Test::UploadedFile.new(
                  File.join(Rails.root, '..', '..', 'spec', 'fixtures', 'images', 'rails_2.png')
                )
              end
            end

            it 'creates a theme_asset on the current site' do
              expect{ post("#{url_prefix}.json", theme_asset: theme_asset) }
                .to change{ Locomotive::ThemeAsset.count }.by(1)
            end
          end
        end

        describe "PUT update" do
          context 'JSON' do
            let(:put_request) { put("#{url_prefix}/#{theme_asset.id}.json", theme_asset: { source: nil }) }

            it 'does not change the number of existing theme assets' do
              expect{ put_request }.to_not change{ Locomotive::ThemeAsset.count }
            end

          end
        end

        describe "DELETE destroy" do
          context 'JSON' do
            let(:delete_request) { delete("#{url_prefix}/#{theme_asset.id}.json") }

            it 'deletes the theme asset' do
              expect{ delete_request }.to change { Locomotive::ThemeAsset.count }.by(-1)
            end

          end
        end

      end

    end
  end
end
