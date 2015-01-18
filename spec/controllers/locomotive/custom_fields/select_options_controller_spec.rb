require 'spec_helper'

describe Locomotive::CustomFields::SelectOptionsController do

  routes { Locomotive::Engine.routes }

  let(:site)          { create(:site, domains: %w{www.acme.com}) }
  let(:account)       { create(:account) }
  let!(:membership) do
    create(:membership, account: account, site: site, role: 'admin')
  end
  let!(:content_type) { create(:content_type, :with_field, site: site) }
  let(:field)         { content_type.entries_custom_fields.last }

  before do
    request_site site
    sign_in account
  end

  describe "#PUT update" do

    let(:attributes) { { site_handle: site, slug: content_type.slug, name: field.name, locale: :en, select_options: [{ name: 'Development' }] } }
    let(:session) { {} }

    subject do
      put :update, attributes, session
    end

    it { is_expected.to redirect_to content_entries_path(site, content_type.slug) }
    specify do
      subject
      expect(assigns(:custom_field).select_options.map(&:name)).to eq ['Development']
    end

    context 'return to another page if success' do

      let(:session) { { return_to: dashboard_path(site) } }
      it { is_expected.to redirect_to dashboard_path(site) }

    end
  end
end
