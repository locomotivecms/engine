require 'spec_helper'

describe Locomotive::MyAccountController do

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

  describe "#GET edit" do
    subject { get :edit, site_handle: site, id: account.id, locale: :en }
    it { is_expected.to be_success }
    specify do
      subject
      expect(assigns(:account)).to be_present
    end
  end

  describe "#PUT update" do
    let(:name) { generate(:name) }
    subject do
      put :update, site_handle: site, id: account.id, locale: :en, account: { name: name }
    end
    it { is_expected.to be_redirect }
    specify do
      subject
      expect(assigns(:account).name).to eq(name)
    end
  end

  describe "#PUT regenerate_api_key" do
    subject do
      put :regenerate_api_key, format: :json
    end
    it { is_expected.to be_success }
  end
end
