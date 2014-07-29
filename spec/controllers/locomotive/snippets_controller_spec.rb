require 'spec_helper'

describe Locomotive::SnippetsController do
  routes { Locomotive::Engine.routes }

  let(:site)     { create(:site, domains: %w{www.acme.com}) }
  let(:account)  { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'admin')
  end
  let!(:snippet)  { create(:snippet, site: site) }

  before do
    Locomotive.config.stubs(:multi_sites?).returns(false)
    sign_in account
  end

  describe "#GET show" do
    subject { get :show, id: snippet.id, locale: :en, format: :json }
    it { should be_success }
  end

  describe "#GET new" do
    subject { get :new, locale: :en }
    it { should be_success }
  end

  describe "#POST create" do
    let(:snippet_attributes) { attributes_for(:snippet, site: site) }
    subject do
      post :create, locale: :en, snippet: snippet_attributes, format: :json
    end
    it { should be_success }
    specify do
      expect { subject }.to change(Locomotive::Snippet, :count).by(+1)
    end
  end

  describe "#GET edit" do
    subject { get :edit, id: snippet.id, locale: :en }
    it { should be_success }
    specify do
      subject
      expect(assigns(:snippet)).to be_present
    end
  end

  describe "#PUT update" do
    let(:new_name) { generate(:name) }
    subject do
      put :update, id: snippet.id, locale: :en, snippet: { name: new_name }, format: :json
    end
    it { should be_success }
    specify do
      subject
      expect(assigns(:snippet).name).to eq(new_name)
    end
  end

  describe "#DELETE destroy" do
    subject do
      delete :destroy, id: snippet.id, locale: :en
    end
    specify do
      expect { subject }.to change(Locomotive::Snippet, :count).by(-1)
    end
  end
end
