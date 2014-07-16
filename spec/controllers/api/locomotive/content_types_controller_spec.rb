require 'spec_helper'

module Locomotive
  module Api
    describe ContentTypesController do

      let(:site)     { create(:site, domains: %w{www.acme.com}) }
      let(:account)  { create(:account) }
      let!(:membership) do
        create(:membership, account: account, site: site, role: 'admin')
      end
      let!(:content_type) { create(:content_type, :with_field, site: site) }

      before do
        Locomotive.config.stubs(:multi_sites?).returns(false)
        sign_in account
      end

      describe "#GET index" do
        subject { get :index, locale: :en, format: :json }
        it { should be_success }
        specify do
          subject
          expect(assigns(:content_types).all).to eq([content_type])
        end
      end

      describe "#GET show" do
        subject { get :show, id: content_type.id, locale: :en, format: :json }
        it { should be_success }
      end

      describe "#POST create" do
        let(:content_type_attributes) do
          attributes_for(:content_type, site: site)
            .merge( entries_custom_fields: [{ label: 'Description', type: 'text' }] )
            .merge( slug: 'content_type_31')
        end
        subject do
          post :create, locale: :en, content_type: content_type_attributes, format: :json
        end
        it { should be_success }
        specify do
          expect { subject }.to change(Locomotive::ContentType, :count).by(+1)
        end
      end

      describe "#PUT update" do
        subject do
          put :update, id: content_type.id, locale: :en, content_type: { }, format: :json
        end
        it { should be_success }
      end

      describe "#DELETE destroy" do
        subject do
          delete :destroy, id: content_type.id, locale: :en, format: :json
        end
        it { should be_success }
        specify do
          expect { subject }.to change(Locomotive::ContentType, :count).by(-1)
        end
      end

    end
  end
end
