require 'spec_helper'

module Locomotive
  describe ContentEntriesController do

    routes { Locomotive::Engine.routes }

    let(:site)     { content_entry.site }
    let(:account)  { create(:account) }
    let!(:membership) do
      create(:membership, account: account, site: site, role: 'admin')
    end
    let(:content_type)   do
      create(:content_type, :with_field).tap do |content_type|
        content_type.entries.create({ title: "title-#{4}-#{rand(10000 * 4)}" })
      end
    end
    let!(:content_entry) { content_type.entries.first }

    before do
      request_site site
      sign_in account
    end

    describe "#GET index" do
      specify do
        expect(content_type.entries).to eq([content_entry])
      end
      specify do
        expect(content_type.entries.count).to eq(1)
      end
      subject { get :index, site_handle: site, locale: :en, slug: content_type.slug }
      it { is_expected.to be_success }
      specify do
        subject
        expect(assigns(:content_entries)).to eq([content_entry])
      end
    end

    describe "#POST create" do
      let(:content_type_attributes) {{ title: "title-#{4}-#{rand(10000 * 4)}" }}
      subject do
        post :create, site_handle: site, locale: :en, slug: content_type.slug, content_entry: content_type_attributes
      end
      it { is_expected.to be_redirect }
      specify do
        expect { subject }.to change(Locomotive::ContentEntry, :count).by(+1)
      end
    end

    describe "#POST :id/clone" do
      subject do
        put :clone, site_handle: site, slug: content_type.slug, id: content_entry.id, locale: :en
      end
      it { is_expected.to be_redirect }
      specify do
        expect { subject }.to change(Locomotive::ContentEntry, :count).by(+1)
      end
    end

    describe "#PUT update" do
      subject do
        put :update, site_handle: site, slug: content_type.slug, id: content_entry.id, locale: :en,
          content_entry: { title: "title-#{4}-#{rand(10000 * 4)}" }
      end
      it { is_expected.to be_redirect }
    end

    describe "#DELETE destroy" do
      subject do
        delete :destroy, site_handle: site, slug: content_type.slug, id: content_entry.id, locale: :en
      end
      it { is_expected.to be_redirect }
      specify do
        expect { subject }.to change(Locomotive::ContentEntry, :count).by(-1)
      end
    end

  end
end
