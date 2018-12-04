describe Locomotive::TranslationsController do

  routes { Locomotive::Engine.routes }

  let(:site)     { create(:site, domains: %w{www.acme.com}) }
  let(:account)  { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'author')
  end
  let!(:translation) { create(:translation, site: site) }

  before do
    request_site site
    sign_in account
  end

  describe "#GET index" do
    subject { get :index, params: { site_handle: site, locale: :en } }
    it { is_expected.to be_successful }
    specify do
      subject
      expect(assigns(:translations).all).to eq([translation])
    end
  end

  describe "#GET edit" do
    subject { get :edit, params: { site_handle: site, id: translation.id, locale: :en } }
    it { is_expected.to be_successful }
    specify do
      subject
      expect(assigns(:translation)).to be_present
    end
  end

  describe "#PUT update" do
    subject do
      put :update, params: {
        site_handle:  site,
        id:           translation.id,
        locale:       :en,
        translation:  { values: { fr: 'foo' } },
        _location:    { filter_by: 'translated', q: 'hell' }
      }
    end
    it { is_expected.to be_redirect }
  end

end
