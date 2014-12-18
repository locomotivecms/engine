require 'spec_helper'

describe Locomotive::ThemeAssetsController do
  routes { Locomotive::Engine.routes }

  let(:site)     { create(:site, domains: %w{www.acme.com}) }
  let(:account)  { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'admin')
  end
  let!(:theme_asset) { create(:theme_asset, site: site, source: rack_upload) }
  let(:path) { Rails.root.join('../../spec/fixtures/images/rails.png').to_s }
  let(:http_upload) do
    ActionDispatch::Http::UploadedFile.new({
      filename: 'rails.png',
      content_type: 'image/png',
      tempfile: File.new(path)
    })
  end
  let(:rack_upload) do
    Rack::Test::UploadedFile.new(path)
  end

  before do
    request_site site
    sign_in account
  end

  describe "#GET index" do
    subject { get :index, locale: :en, format: :json }
    it { is_expected.to be_success }
  end

  describe "#GET new" do
    subject { get :new, locale: :en }
    it { is_expected.to be_success }
  end

  describe "#POST create" do
    let(:theme_asset_attributes) do
      attributes_for(:theme_asset, site: site).tap do |attributes|
        attributes[:source] = Rack::Test::UploadedFile.new(
          File.join(Rails.root, '..', '..', 'spec', 'fixtures', 'images', 'rails_2.png')
        )
      end
    end
    subject do
      post :create, locale: :en, theme_asset: theme_asset_attributes, format: :json
    end
    it { is_expected.to be_success }
    specify do
      expect { subject }.to change(Locomotive::ThemeAsset, :count).by(+1)
    end
  end

  describe "#GET edit" do
    subject { get :edit, id: theme_asset.id, locale: :en }
    it { is_expected.to be_success }
    specify do
      subject
      expect(assigns(:theme_asset)).to be_present
    end
  end

  describe "#PUT update" do
    subject do
      put :update, id: theme_asset.id, locale: :en, theme_asset: { }, format: :json
    end
    it { is_expected.to be_success }
  end

  describe "#DELETE destroy" do
    subject do
      delete :destroy, id: theme_asset.id, locale: :en
    end
    specify do
      expect { subject }.to change(Locomotive::ThemeAsset, :count).by(-1)
    end
  end
end
