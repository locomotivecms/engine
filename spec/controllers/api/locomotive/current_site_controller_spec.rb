require 'spec_helper'

module Locomotive
  module Api

    describe CurrentSiteController do
      let(:site)     { create(:site, domains: %w{www.acme.com}) }
      let(:account)  { create(:account) }
      let!(:membership) do
        create(:membership, account: account, site: site, role: 'admin')
      end

      before do
        Locomotive.config.stubs(:multi_sites?).returns(false)
        sign_in account
      end

      describe "#GET show" do
        subject { get :show, id: 123, locale: :en, format: :json }
        it { should be_success }
        specify do
          subject
          expect(assigns(:site)).to be_present
        end
      end

      describe "#DELETE destroy" do
        subject do
          delete :destroy, id: site.id, locale: :en, format: :json
        end
        it { should be_success }
        specify do
          expect { subject }.to change(Locomotive::Site, :count).by(-1)
        end
      end

    end
  end
end
