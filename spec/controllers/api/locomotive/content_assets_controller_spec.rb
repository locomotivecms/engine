require 'spec_helper'

module Locomotive
  module Api
    describe ContentAssetsController do

      let(:site)     { create(:site, domains: %w{www.acme.com}) }
      let(:account)  { create(:account) }
      let!(:membership) do
        create(:membership, account: account, site: site, role: 'admin')
      end
      let!(:content_asset) { create(:asset, site: site) }

      before do
        request_site site
        sign_in account
      end

      describe "#GET index" do
        subject { get :index, locale: :en, format: :json }
        it { is_expected.to be_success }
        specify do
          subject
          expect(assigns(:content_assets).all).to eq([content_asset])
        end
      end

      describe "#GET show" do
        subject { get :show, id: content_asset.id, locale: :en, format: :json }
        it { is_expected.to be_success }
      end

      describe "#POST create" do
        let(:content_asset_attributes) do
          attributes_for(:asset, site: site)
        end
        subject do
          post :create, locale: :en, content_asset: content_asset_attributes, format: :json
        end
        it { is_expected.to be_success }
        specify do
          expect { subject }.to change(Locomotive::ContentAsset, :count).by(+1)
        end
      end

      describe "#PUT update" do
        let(:path) { Rails.root.join('../../spec/fixtures/images/logo1.jpg').to_s }
        let(:upload) do
          ActionDispatch::Http::UploadedFile.new({
            filename: 'logo1.jpg',
            content_type: 'image/jpeg',
            tempfile: File.new(path)
          })
        end
        subject do
          put :update, id: content_asset.id, locale: :en, content_asset: { source: upload }, format: :json
        end
        it { is_expected.to be_success }
        specify do
          subject
          expect(assigns(:content_asset).attributes['source_filename']).to eq('logo1.jpg')
        end
      end

      describe "#DELETE destroy" do
        let!(:content_asset) { create(:asset) }
        subject do
          delete :destroy, id: content_asset.id, locale: :en, format: :json
        end
        it { is_expected.to be_success }
        specify do
          expect { subject }.to change(Locomotive::ContentAsset, :count).by(-1)
        end
      end

    end
  end
end
