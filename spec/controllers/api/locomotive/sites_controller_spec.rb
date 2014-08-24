require 'spec_helper'

module Locomotive
  module Api
    describe SitesController do

      let(:site)     { create(:site, domains: %w{www.acme.com}) }
      let(:account)  { create(:account) }

      let!(:membership) do
        create(:membership, account: account, site: site, role: 'admin')
      end

      before do
        Locomotive.config.stubs(:multi_sites?).returns(false)
        sign_in account
      end

      describe "#GET index" do
        subject { get(:index, locale: :en, format: :json) }
        it { should be_success }
      end

      describe "#GET show" do
        subject { get :show, id: 42, locale: :en, format: :json }
        it { should be_success }
      end

      describe "#POST create" do
        subject do
          post :create, id: 42, locale: :en, site: { subdomain: generate(:subdomain), name: generate(:name) },
            format: :json
        end
        it { should be_success }
        specify do
          expect { subject }.to change(Locomotive::Site, :count).by(+1)
        end
      end

      describe "#PUT update" do
        let!(:site) { create(:site) }
        let(:new_name) { generate(:name) }
        subject do
          put :update, id: site.id, locale: :en, site: { name: new_name }, format: :json
        end
        it { should be_success }
        specify do
          expect(JSON.parse(subject.body).fetch('name')).to eq(new_name)
        end
      end

      describe "#DELETE destroy" do
        let!(:site) { create(:site) }
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
