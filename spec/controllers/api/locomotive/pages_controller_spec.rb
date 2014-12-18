require 'spec_helper'

module Locomotive
  module Api
    describe PagesController do

      let(:site)     { create(:site, domains: %w{www.acme.com}) }
      let(:account)  { create(:account) }
      let!(:membership) do
        create(:membership, account: account, site: site, role: 'admin')
      end
      let(:page) { site.pages.root.first }

      before do
        request_site site
        sign_in account
      end

      describe "#GET index" do
        subject { get :index, locale: :en, format: :json }
        it { is_expected.to be_success }
        specify do
          subject
          expect(assigns(:pages).to_a).to eq(site.pages.all)
        end
      end

      describe "#GET show" do
        subject { get :show, id: page.id, locale: :en, format: :json }
        it { is_expected.to be_success }
      end

      describe "#POST create" do
        let(:page_attributes)  do
          attributes_for(:sub_page, parent_id: site.pages.root.first._id)
        end
        subject do
          post :create, locale: :en, page: page_attributes, format: :json
        end
        it { is_expected.to be_success }
        specify do
          expect { subject }.to change(Locomotive::Page, :count).by(+1)
        end
      end

      describe "#PUT update" do
        let(:new_name) { generate(:name) }
        subject do
          put :update, id: page.id, locale: :en, page: { title: new_name }, format: :json
        end
        it { is_expected.to be_success }
        specify do
          expect(JSON.parse(subject.body).fetch('title')).to eq(new_name)
        end
      end

      describe "#DELETE destroy" do
        let!(:child_page) { create(:sub_page, parent: page, site: site) }
        subject do
          delete :destroy, id: child_page.id, locale: :en, format: :json
        end
        it { is_expected.to be_success }
        specify do
          expect { subject }.to change(Locomotive::Page, :count).by(-1)
        end
      end

    end
  end
end
