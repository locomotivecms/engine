require 'spec_helper'

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
    subject { get :new, locale: :en }
    it { is_expected.to be_success }
  end

  describe "#POST create" do
    let(:site_attributes) do
      { handle: generate(:handle), name: generate(:name) }
    end
    subject do
      post :create, locale: :en, site: site_attributes
    end
    it { is_expected.to be_redirect }
    specify do
      expect { subject }.to change(Locomotive::Site, :count).by(+1)
    end
  end

end
