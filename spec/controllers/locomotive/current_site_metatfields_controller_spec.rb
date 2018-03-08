describe Locomotive::CurrentSiteMetafieldsController do

  routes { Locomotive::Engine.routes }

  let(:site)     { create(:site, domains: %w{www.acme.com}, metafields_schema: [{ 'name' => 'theme', 'fields' => [{ 'name' => 'background_color' }] }]) }
  let(:account)  { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'admin')
  end

  before do
    request_site site
    sign_in account
  end

  describe "#GET index" do
    subject { get :index, params: { site_handle: site, locale: :en } }
    it { is_expected.to be_success }
    specify do
      subject
      expect(assigns(:site)).to be_present
    end
  end

  describe "#PUT update_all" do
    subject do
      put :update_all, params: { site_handle: site, locale: :en, site: { name: 'foooo', metafields: { theme: { background_color: '#f00' } } } }
    end
    it { is_expected.to be_redirect }
    specify do
      subject
      expect(assigns(:site).metafields['theme']['background_color']).to eq('#f00')
      expect(assigns(:site).name).not_to eq('foooo')
    end
  end

end
