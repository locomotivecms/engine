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

  describe '#GET index' do
    subject { get :index, params: { site_handle: site, locale: :en } }
    it { is_expected.to be_successful }
    specify do
      subject
      expect(assigns(:content_assets).all).to eq([content_asset])
    end
  end

  describe '#POST create' do
    let(:content_asset_attributes) do
      attributes_for(:asset, site: site)
    end
    subject do
      post :create, params: { site_handle: site, locale: :en, content_asset: content_asset_attributes }
    end
    it { is_expected.to be_redirect }
    specify do
      expect { subject }.to change(Locomotive::ContentAsset, :count).by(1)
    end
  end

  describe '#POST bulk_create' do
    let(:content_assets_attributes) do
      [
        { source: rack_asset('5k.png') },
        { source: rack_asset('5k_2.png') }
      ]
    end
    subject do
      post :bulk_create, params: { site_handle: site, locale: :en, content_assets: content_assets_attributes, format: :json }
    end
    it { is_expected.to be_success }
    specify do
      expect { subject }.to change(Locomotive::ContentAsset, :count).by(2)
    end
  end

  describe '#DELETE destroy' do
    let!(:content_asset) { create(:asset) }
    subject do
      delete :destroy, params: { site_handle: site, id: content_asset.id, locale: :en }
    end
    it { is_expected.to be_redirect }
    specify do
      expect { subject }.to change(Locomotive::ContentAsset, :count).by(-1)
    end
  end

end
