require 'spec_helper'

describe Locomotive::MembershipsController do
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

  describe "#POST create" do
    let(:email) { generate(:email) }
    let(:membership_attributes) do
      { email: email }
    end
    subject do
      post :create, locale: :en, membership: membership_attributes
    end
    it { should redirect_to new_account_path(email: email) }
    specify do
      expect { subject }.to_not change(Locomotive::Membership, :count)
    end
  end

  describe "#DELETE destroy" do
    subject do
      delete :destroy, id: membership.id, locale: :en
    end
    it { should redirect_to edit_current_site_path }
  end
end
