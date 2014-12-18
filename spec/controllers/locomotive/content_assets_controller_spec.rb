require 'spec_helper'

describe Locomotive::ContentAssetsController do

  routes { Locomotive::Engine.routes }

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
    specify do
      expect(get: '/content_assets', action: 'index').to route_to(
        controller: 'locomotive/content_assets', action: 'index')
    end
    subject { get :index, locale: :en }
    it { is_expected.to be_success }
    specify do
      subject
      expect(assigns(:content_assets).all).to eq([content_asset])
    end
  end

  describe "#POST create" do
    let(:content_asset_attributes) do
      attributes_for(:asset, site: site)
    end
    subject do
      post :create, locale: :en, content_asset: content_asset_attributes
    end
    it { is_expected.to be_redirect }
    specify do
      expect { subject }.to change(Locomotive::ContentAsset, :count).by(+1)
    end
  end

  describe "#DELETE destroy" do
    let!(:content_asset) { create(:asset) }
    subject do
      delete :destroy, id: content_asset.id, locale: :en
    end
    it { is_expected.to be_success }
    specify do
      expect { subject }.to change(Locomotive::ContentAsset, :count).by(-1)
    end
  end

end
