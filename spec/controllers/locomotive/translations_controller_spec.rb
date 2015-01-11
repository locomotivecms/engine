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
    subject { get :index, locale: :en }
    it { is_expected.to be_success }
    specify do
      subject
      expect(assigns(:translations).all).to eq([translation])
    end
  end

  describe "#GET new" do
    subject { get :new, locale: :en }
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
      post :create, locale: :en, translation: translation_attributes, format: :json
    end
    it { is_expected.to be_success }
    specify do
      expect { subject }.to change(Locomotive::Translation, :count).by(+1)
    end
  end

  describe "#GET edit" do
    subject { get :edit, id: translation.id, locale: :en }
    it { is_expected.to be_success }
    specify do
      subject
      expect(assigns(:translation)).to be_present
    end
  end

  describe "#PUT update" do
    subject do
      put :update, id: translation.id, locale: :en, translation: { key: 'foo' }, format: :json
    end
    it { is_expected.to be_success }
  end

  describe "#DELETE destroy" do
    subject do
      delete :destroy, id: translation.id, locale: :en
    end
    it { is_expected.to redirect_to translations_path }
    specify do
      expect { subject }.to change(Locomotive::Translation, :count).by(-1)
    end
  end

end
