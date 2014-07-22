require 'spec_helper'

module Locomotive
  module Api
    describe ContentEntriesController, pending: true do

      let(:site)     { content_entry.site }
      let(:account)  { create(:account) }
      let!(:membership) do
        create(:membership, account: account, site: site, role: 'admin')
      end
      let(:content_type)   { content_entry.content_type }
      let!(:content_entry) { create(:content_entry) }

      before do
        Locomotive.config.stubs(:multi_sites?).returns(false)
        sign_in account
      end

      describe "#GET index" do
        subject { get :index, locale: :en, slug: content_type.slug, format: :json }
        it { should be_success }
        specify do
          subject
          expect(assigns(:content_entries).all).to eq([content_entries])
        end
      end

      describe "#GET show" do
        subject { get :show, id: content_entry.id, locale: :en, format: :json }
        it { should be_success }
      end

      # describe "#POST create" do
      #   let(:content_type_attributes) do
      #     attributes_for(:content_entry, site: site)
      #       .merge( entries_custom_fields: [{ label: 'Description', type: 'text' }] )
      #       .merge( slug: 'content_type_31')
      #   end
      #   subject do
      #     post :create, locale: :en, content_entry: content_type_attributes, format: :json
      #   end
      #   it { should be_success }
      #   specify do
      #     expect { subject }.to change(Locomotive::ContentEntry, :count).by(+1)
      #   end
      # end
      #
      # describe "#PUT update" do
      #   subject do
      #     put :update, id: content_entry.id, locale: :en, content_entry: { }, format: :json
      #   end
      #   it { should be_success }
      # end

      describe "#DELETE destroy" do
        subject do
          delete :destroy, id: content_entry.id, locale: :en, format: :json
        end
        it { should be_success }
        specify do
          expect { subject }.to change(Locomotive::ContentEntry, :count).by(-1)
        end
      end

    end
  end
end
