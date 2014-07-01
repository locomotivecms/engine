require 'spec_helper'

module Locomotive
  module Api
    describe SitesController do

      let(:site)     { FactoryGirl.create(:site, domains: %w{www.acme.com}) }
      let(:account)  { FactoryGirl.create(:account) }

      let!(:membership) do
        FactoryGirl.create(:membership, account: account, site: site, role: 'designer')
      end

      before do
        controller.expects(:current_locomotive_account).at_least_once.returns(account)
        controller.instance_variable_set(:@current_site, site)
        controller.expects(:require_account).at_least_once.returns(nil)
        controller.expects(:current_site).at_least_once.returns(site)
      end

      describe "#GET index" do
        subject { get :index, locale: :en, format: :json }
        it { should be_success }
      end

      describe "#GET show" do
        subject { get :show, id: 42, locale: :en, format: :json }
        it { should be_success }
      end
    end
  end
end
