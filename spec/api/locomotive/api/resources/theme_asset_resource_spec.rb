require 'spec_helper'

describe Locomotive::API::Resources::ThemeAssetResource do

  include_context 'api site setup'

  let!(:theme_asset)  { create(:theme_asset, site: site, source: rack_theme_image('rails.png')) }
  let(:params)        { { locale: :en } }
  let(:url_prefix)    { '/locomotive/acmi/api/v3/theme_assets' }

  context 'authenticated site' do
    include_context 'api header setup'

    describe 'GET index' do
      context 'JSON' do
        before { get "#{url_prefix}.json" }
        it 'returns a successful response' do
          expect(last_response).to be_successful
        end
      end
    end

    describe 'GET checksums' do
      context 'JSON' do
        before { get "#{url_prefix}/checksums.json" }
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
            attributes[:source] = rack_theme_image('rails_2.png')
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
