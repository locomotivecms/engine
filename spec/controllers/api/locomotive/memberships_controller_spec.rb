require 'spec_helper'

module Locomotive
  module Api

    describe MembershipsController do
      let(:account)     { create(:account) }
      let(:account_bis) { create('frenchy user') }
      let(:site)    { create(:site, domains: %w{www.acme.com}) }
      let!(:membership) do
        create(:membership, account: account, site: site, role: 'admin')
      end

      before do
        request_site site
        sign_in account
      end

      describe "#GET index" do
        subject { get :index, locale: :en, format: :json }
        it { should be_success }
        specify do
          subject
          expect(assigns(:memberships)).to eq([membership])
        end
      end

      describe "#GET show" do
        subject { get :show, id: membership.id, locale: :en, format: :json }
        it { should be_success }
      end

      describe "#POST create" do
        let(:membership_attributes) { { account_id: account_bis._id, role: 'author' } }
        subject do
          post :create, locale: :en, membership: membership_attributes, format: :json
        end
        it { should be_success }
        specify do
          subject
          expect(assigns(:membership).persisted?).to eq(true)
        end
      end

      describe "#PUT update" do
        let!(:membership_bis) do
          create(:membership, account: account_bis, site: site, role: 'author')
        end
        let(:membership_attributes) { { role: 'designer' } }
        subject do
          put :update, id: membership_bis._id, locale: :en, membership: membership_attributes, format: :json
        end
        it { should be_success }
        specify do
          subject
          expect(assigns(:membership).role).to eq('designer')
        end
      end

      describe "#DELETE destroy" do
        let!(:membership_bis) do
          create(:membership, account: account_bis, site: site, role: 'author')
        end
        subject do
          delete :destroy, id: membership_bis._id, locale: :en, format: :json
        end
        it { should be_success }
      end

    end
  end
end
