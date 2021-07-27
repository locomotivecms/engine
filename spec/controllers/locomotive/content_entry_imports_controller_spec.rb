module Locomotive
  describe ContentEntryImportsController do    

    routes { Locomotive::Engine.routes }

    let(:site)     { content_type.site }
    let(:account)  { create(:account) }
    let!(:membership) do
      create(:membership, account: account, site: site, role: 'admin')
    end
    let(:content_type) { create(:content_type, :with_field, :import_enabled) }

    before do
      request_site site
      sign_in account
    end

    describe "#GET show" do
      subject { get :show, params: { site_handle: site, locale: :en, slug: content_type.slug } }
      it { is_expected.to be_successful }
      context 'the import feature is off' do
        let(:content_type) { create(:content_type, :with_field) }
        it { is_expected.to be_redirect }
      end
    end

    describe '#GET new' do
      subject { get :new, params: { site_handle: site, locale: :en, slug: content_type.slug } }
      it { is_expected.to be_successful }
      context 'the import feature is off' do
        let(:content_type) { create(:content_type, :with_field) }
        it { is_expected.to be_redirect }
      end
    end

    describe '#POST create' do      
      let(:attributes) { { file: rack_asset('articles.csv'), col_sep: ';' } }
      subject { post :create, params: { site_handle: site, locale: :en, slug: content_type.slug, content_entry_import: attributes } }
      it 'triggers the async import task' do 
        expect_any_instance_of(Locomotive::ContentEntryImportService).to receive(:async_import).with(anything, { col_sep: ';', quote_char: "\"" })
        is_expected.to be_redirect
      end
      context 'the file is missing' do
        let(:attributes) { { file: '' } }
        it { is_expected.to be_successful }
      end
      context 'the import feature is off' do
        let(:content_type) { create(:content_type, :with_field) }
        it { is_expected.to be_redirect }
      end
    end

    describe '#DELETE destroy' do
      subject { delete :destroy, params: { site_handle: site, locale: :en, slug: content_type.slug } }
      it 'cancels the import' do 
        expect_any_instance_of(Locomotive::ContentEntryImportService).to receive(:cancel)
        is_expected.to be_redirect
      end
      context 'the import feature is off' do
        let(:content_type) { create(:content_type, :with_field) }
        it { is_expected.to be_redirect }
      end
    end
  end
end