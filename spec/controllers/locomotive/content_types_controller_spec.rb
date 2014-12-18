require 'spec_helper'

describe Locomotive::ContentTypesController do
  routes { Locomotive::Engine.routes }

  let(:site)     { create(:site, domains: %w{www.acme.com}) }
  let(:account)  { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'admin')
  end
  let!(:content_type) { create(:content_type, :with_field, site: site) }

  before do
    request_site site
    sign_in account
  end

  describe "#GET edit" do
    subject { get :edit, id: content_type.id, locale: :en }
    it { is_expected.to be_success }
  end

  describe "#POST create" do
    let(:content_type_attributes) do
      attributes_for(:content_type, site: site)
        .merge( entries_custom_fields: [{ label: 'Description', type: 'text' }] )
        .merge( slug: 'content_type_31')
    end
    subject do
      post :create, locale: :en, content_type: content_type_attributes, format: :json
    end
    it { is_expected.to be_success }
    specify do
      expect { subject }.to change(Locomotive::ContentType, :count).by(+1)
    end
  end

  describe "#PUT update" do
    subject do
      put :update, id: content_type.id, locale: :en, content_type: { }, format: :json
    end
    it { is_expected.to be_success }
  end

  describe "#DELETE destroy" do
    subject do
      delete :destroy, id: content_type.id, locale: :en, format: :json
    end
    it { is_expected.to be_success }
    specify do
      expect { subject }.to change(Locomotive::ContentType, :count).by(-1)
    end
  end

end
