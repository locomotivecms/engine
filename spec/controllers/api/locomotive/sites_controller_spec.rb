require 'spec_helper'

module Locomotive
  module Api
    describe SitesController do

      let(:site)     { create(:site, domains: %w{www.acme.com}) }
      let(:account)  { create(:account) }

      let!(:membership) do
        create(:membership, account: account, site: site, role: 'admin') #'designer')
      end

      before do
        controller.stubs(:current_site).returns(site)
        sign_in account
      end

      describe "#GET index" do
        subject { get :index, locale: :en, format: :json }
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

    end
  end
end
