require 'spec_helper'

describe Locomotive::PagesController do
  routes { Locomotive::Engine.routes }

  let(:site)     { create(:site, domains: %w{www.acme.com}) }
  let(:account)  { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'admin')
  end
  let(:page) { site.pages.root.first }

  before do
    Locomotive.config.stubs(:multi_sites?).returns(false)
    sign_in account
  end

  describe "#GET index" do
    subject { get :index, locale: :en }
    it { should be_success }
  end

  describe "#GET show" do
    subject { get :show, id: page.id, locale: :en, format: :json }
    it { should be_success }
  end

  describe "#GET new" do
    subject { get :new, locale: :en }
    it { should be_success }
  end

  describe "#POST create" do
    let(:page_attributes)  do
      attributes_for(:page, site: site, parent: site.pages.root.first)
    end
    subject do
      post :create, locale: :en, page: page_attributes, format: :json
    end
    it { should be_success }
    specify do
      expect { subject }.to change(Locomotive::Page, :count).by(+1)
    end
  end

  describe "#GET edit" do
    subject { get :edit, id: page.id, locale: :en }
    it { should be_success }
    specify do
      subject
      expect(assigns(:page)).to be_present
    end
  end

  describe "#PUT update" do
    let(:title) { generate(:name) }
    subject do
      put :update, id: page.id, locale: :en, page: { title: title }, format: :json
    end
    it { should be_success }
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
        delete :destroy, id: child_page.id, locale: :en
      end
      specify do
        expect { subject }.to change(Locomotive::Page, :count).by(-1)
      end
    end

    describe "#PUT sort" do
      subject do
        put :sort, id: page.id, children: [child_page.id], locale: :en, format: :json
      end
      it { should be_success }
    end

    describe "#GET get_path" do
      subject { get :get_path, parent_id: page.id, slug: page.slug, locale: :en }
      it { should be_success }
    end
  end
end
