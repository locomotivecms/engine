describe Locomotive::PagesController do

  routes { Locomotive::Engine.routes }

  let(:site)     { create(:site, domains: %w{www.acme.com}) }
  let(:account)  { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'admin')
  end
  let(:page) { site.pages.home.first }

  before do
    request_site site
    sign_in account
  end

  # FIXME: no more index action
  # describe "#GET index" do
  #   subject { get :index, site_handle: site, locale: :en }
  #   it { is_expected.to be_successful }
  # end

  describe "#GET new" do
    subject { get :new, params: { site_handle: site, locale: :en } }
    it { is_expected.to be_successful }
  end

  describe "#POST create" do
    let(:page_attributes)  do
      attributes_for(:sub_page, parent_id: site.pages.home.first._id, raw_template: 'Hello world')
    end
    subject do
      post :create, params: { site_handle: site, locale: :en, page: page_attributes }
    end
    it { is_expected.to be_redirect }
    specify do
      expect { subject }.to change(Locomotive::Page, :count).by(+1)
    end
  end

  describe "#GET edit" do
    subject { get :edit, params: { site_handle: site, id: page.id, locale: :en } }
    it { is_expected.to be_successful }
    specify do
      subject
      expect(assigns(:page)).to be_present
    end
  end

  describe "#PUT update" do
    let(:title) { generate(:name) }
    subject do
      put :update, params: { site_handle: site, id: page.id, locale: :en, page: { title: title } }
    end
    it { is_expected.to be_redirect }
    specify do
      subject
      expect(assigns(:page).title).to eq(title)
    end
  end

  context 'with child' do
    let!(:child_page) do
      parent = page
      child  = build(:page)
      child.parent = parent
      child.save!
      child
    end

    describe "#DELETE destroy" do
      subject do
        delete :destroy, params: { site_handle: site, id: child_page.id, locale: :en }
      end
      specify do
        expect { subject }.to change(Locomotive::Page, :count).by(-1)
      end
    end

    describe "#PUT sort" do
      subject do
        put :sort, params: { site_handle: site, id: page.id, children: [child_page.id], locale: :en, format: :json }
      end
      it { is_expected.to be_successful }
    end

  end
end
