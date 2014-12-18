require 'spec_helper'

module Locomotive
  module Api

    describe CurrentSiteController do
      let(:site)      { create(:site, domains: %w{www.acme.com}) }
      let(:account)   { create(:account) }
      let(:token)     { account_token(account) }
      let!(:membership) do
        create(:membership, account: account, site: site, role: 'admin')
      end
      let(:params)    { { locale: :en, token: token, format: :json } }

      before { request_site(site) }

      describe "#GET show" do
        subject { get :show, params.merge(id: 123) }
        it { is_expected.to be_success }
        specify do
          subject
          expect(assigns(:site)).to be_present
        end

        context 'passign the authentication token in the http header' do
          before do
            Locomotive.config.stubs(:unsafe_token_authentication).returns(false)
            request.headers['X-Locomotive-Account-Token'] = token
            request.headers['X-Locomotive-Account-Email'] = account.email
          end
          subject { get(:show, params.merge(id: 123)) }
          it { is_expected.to be_success }
        end
      end

      describe "#PUT update" do
        subject do
          put :update, params.merge(site: { name: 'My website' })
        end
        it { is_expected.to be_success }
      end

      describe "#DELETE destroy" do
        subject do
          delete :destroy, params.merge(id: site.id)
        end
        it { is_expected.to be_success }
        specify do
          expect { subject }.to change(Locomotive::Site, :count).by(-1)
        end
      end

    end
  end
end
