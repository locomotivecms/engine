require 'spec_helper'

describe Locomotive::CurrentSiteController do
  routes { Locomotive::Engine.routes }

  let(:site)     { create(:site, domains: %w{www.acme.com}) }
  let(:account)  { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'admin')
  end

  before do
    Locomotive.config.stubs(:multi_sites?).returns(false)
    sign_in account
  end

  describe "#GET edit" do
    subject { get :edit, id: site.id, locale: :en }
    it { should be_success }
    specify do
      subject
      expect(assigns(:site)).to be_present
    end
  end

  describe "#PUT update" do
    subject do
      put :update, id: site.id, locale: :en, site: { name: 'foooo' }, format: :json
    end
    it { should be_success }
    specify do
      subject
      expect(assigns(:site).name).to eq('foooo')
    end
  end
end
