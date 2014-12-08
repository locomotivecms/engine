require 'spec_helper'

describe Locomotive::AccountsController do

  routes { Locomotive::Engine.routes }

  let(:site)    { create(:site, domains: %w{www.acme.com}) }
  let(:account) { create(:account) }
  let(:role)    { 'admin' }
  let!(:membership) do
    create(:membership, account: account, site: site, role: role)
  end

  before do
    Locomotive.config.stubs(:multi_sites?).returns(false)
    sign_in account
  end

  describe "#POST create" do
    let(:account_attributes) do
      attributes_for('frenchy user', site: site)
    end
    subject do
      post :create, locale: :en, account: account_attributes
    end
    it { should be_redirect }
    specify do
      expect { subject }.to change(Locomotive::Account, :count).by(+1)
    end

    context 'when logged in as a designer' do
      let(:role) { 'author' }
      it { should be_redirect }
      specify do
        expect { subject }.not_to change(Locomotive::Account, :count).by(+1)
      end

    end
  end

end
