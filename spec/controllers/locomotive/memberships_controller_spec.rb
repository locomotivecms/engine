describe Locomotive::MembershipsController do

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

  describe "#POST create" do
    let(:email) { generate(:email) }
    let(:membership_attributes) { { email: email } }
    subject do
      post :create, params: { site_handle: site, locale: :en, membership: membership_attributes }
    end
    it { is_expected.to redirect_to new_account_path(site, email: email) }

    describe 'no existing membership' do
      let(:another_account) { create(:account) }
      let(:email) { another_account.email }
      it { is_expected.to redirect_to edit_current_site_path }
    end

    describe 'existing membership' do
      let(:email) { account.email }
      it { expect(subject.code).to eq('200') }
    end

  end

  describe "#DELETE destroy" do
    subject do
      delete :destroy, params: { site_handle: site, id: membership.id, locale: :en }
    end
    it { is_expected.to redirect_to edit_current_site_path(site) }
  end
end
