describe Locomotive::SitesController do

  routes { Locomotive::Engine.routes }

  let(:site)     { create(:site, domains: %w{www.acme.com}) }
  let(:account)  { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'admin')
  end

  before do
    request_site site
    sign_in account
  end

  describe "#GET new" do
    subject { get :new, params: { locale: :en } }
    it { is_expected.to be_successful }
  end

  describe "#POST create" do
    let(:site_attributes) do
      { handle: generate(:handle), name: generate(:name) }
    end
    subject do
      post :create, params: { locale: :en, site: site_attributes }
    end
    it { is_expected.to be_redirect }
    specify do
      expect { subject }.to change(Locomotive::Site, :count).by(+1)
    end
  end

end
