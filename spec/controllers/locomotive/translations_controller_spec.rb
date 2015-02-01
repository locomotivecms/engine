require 'spec_helper'

describe Locomotive::TranslationsController do

  routes { Locomotive::Engine.routes }

  let(:site)     { create(:site, domains: %w{www.acme.com}) }
  let(:account)  { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'admin')
  end
  let!(:translation) { create(:translation, site: site) }

  before do
    request_site site
    sign_in account
  end

  describe "#GET index" do
    subject { get :index, site_handle: site, locale: :en }
    it { is_expected.to be_success }
    specify do
      subject
      expect(assigns(:translations).all).to eq([translation])
    end
  end

  describe "#GET new" do
    subject { get :new, site_handle: site, locale: :en }
    it { is_expected.to be_success }
    specify do
      subject
      expect(assigns(:translation)).to be_new_record
    end
  end

  describe "#POST create" do
    let(:translation_attributes) do
      attributes_for(:translation, site: site)
    end
    subject do
      post :create, site_handle: site, locale: :en, translation: translation_attributes
    end
    it { is_expected.to be_redirect }
    specify do
      expect { subject }.to change(Locomotive::Translation, :count).by(+1)
    end
  end

  describe "#GET edit" do
    subject { get :edit, site_handle: site, id: translation.id, locale: :en }
    it { is_expected.to be_success }
    specify do
      subject
      expect(assigns(:translation)).to be_present
    end
  end

  describe "#PUT update" do
    subject do
      put :update, site_handle: site, id: translation.id, locale: :en, translation: { key: 'foo' }
    end
    it { is_expected.to be_redirect }
  end

  describe "#DELETE destroy" do
    subject do
      delete :destroy, site_handle: site, id: translation.id, locale: :en
    end
    it { is_expected.to redirect_to translations_path(site) }
    specify do
      expect { subject }.to change(Locomotive::Translation, :count).by(-1)
    end
  end

end
