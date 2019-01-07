describe Locomotive::CustomFields::SelectOptionsController do

  routes { Locomotive::Engine.routes }

  let(:site)          { create(:site, domains: %w{www.acme.com}, locales: [:en, :fr]) }
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

    let(:locale)      { :en }
    let(:options)     { [{ name: 'Development' }] }
    let(:attributes)  { { site_handle: site, slug: content_type.slug, name: field.name, content_locale: locale, select_options: options } }
    let(:session)     { {} }

    subject do
      put :update, params: attributes, session: session
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

    context 'in another locale' do

      let(:locale)  { :fr }
      let(:options) { [{ _id: field.select_options.first._id, name: 'Développement' }, { name: 'Marketing' }] }

      before do
        field.update_attributes(select_options_attributes: [{ name: 'Development' }])
        content_type.save
      end

      it 'translates the existing option and also define new ones in the default locale' do
        subject
        expect(assigns(:custom_field).select_options.map(&:name)).to eq ['Développement', 'Marketing']

        ::Mongoid::Fields::I18n.with_locale(:en) do
          expect(content_type.reload.entries_custom_fields.last.select_options.map(&:name)).to eq ['Development', 'Marketing']
        end
      end

    end

  end
end
