# encoding: utf-8

describe Locomotive::ContentEntryImportService do

  let(:site)                  { create('test site') }
  let(:content_type)          { create_content_type }
  let(:authors_content_type)  { create_authors_content_type }
  let(:service)               { described_class.new(content_type) }
  let(:csv_asset)             { create(:asset, site: site, source: FixturedAsset.open('articles.csv')) }

  describe '#async_import' do
    let(:csv_file) { rack_asset('5k.png') }
    let(:csv_options) { { col_sep: ';' } }
    subject { service.async_import(csv_file, csv_options) }
    it 'saves the asset and enqueues a new import job' do
      expect(Locomotive::ImportContentEntryJob).to receive(:perform_later)
      expect {
        subject
      }.to change { site.content_assets.count }.by(1)
    end
  end

  describe '#import' do
    let(:csv_options) { { col_sep: ';' } }
    subject { service.import(csv_asset.id, csv_options) }

    context "the CSV file doesn't exist anymore" do
      subject { service.import('unknown-asset-id', {}) }
      it 'cancels the import' do
        expect(content_type).to receive(:cancel_import).with('The CSV file doesn\'t exist anymore')
        subject
      end
    end

    context 'the CSV file is bogus' do
      let(:csv_asset) { create(:asset, site: site, source: FixturedAsset.open('5k.png')) }
      it 'cancels the import' do
        expect(content_type).to receive(:cancel_import).with("Unquoted fields do not allow new line <\"\\r\"> in line 5.")
        subject
      end
    end

    context 'the CSV file is valid' do
      before do
        create_content_type_relationships
        site.content_assets.create(source: FixturedAsset.open('5k.png'))
        content_type.entries.create(_slug: 'first-article', title: 'First article')
        content_type.entries.create(_slug: 'lorem-ipsum', title: 'Second article')
        authors_content_type.entries.create!(name: 'John Doe', _slug: 'john-doe')
        authors_content_type.entries.create!(name: 'Jane Doe', _slug: 'jane-doe')
      end
    
      it 'creates/updates as many entries as there are rows in the CSV' do
        expect { subject }.to change(content_type.entries, :count).by(2)
        .and change { content_type.import_status }.from(:ready).to(:done)
        .and change { content_type.import_state.created_rows_count }.from(0).to(2)
        .and change { content_type.import_state.updated_rows_count }.from(0).to(2)
        .and change { content_type.import_state.failed_rows_count }.from(0).to(1)

        entry = content_type.entries.first.reload
        expect(entry._slug).to eq 'first-article'
        expect(entry.title).to eq 'Hello world'
        expect(entry.banner_asset_url).to match /\/sites\/[^\/]+\/assets\/[^\/]+\/5k.png$/
        expect(entry.category).to eq 'Development'
        expect(entry.author.name).to eq 'John Doe'
        expect(entry.reviewers.pluck(:name)).to eq(['John Doe', 'Jane Doe'])

        entry = content_type.entries.last.reload
        expect(entry._slug).to eq 'my-article'
        expect(entry.title).to eq 'My article with its own slug'
      end
    end
  end

  def create_content_type    
    build(:content_type, site: site, name: 'Articles').tap do |content_type|
      content_type.entries_custom_fields.build(name: 'title', type: 'string', label: 'Title')
      content_type.entries_custom_fields.build(name: 'body', type: 'text', label: 'Body')
      content_type.entries_custom_fields.build(name: 'published', type: 'boolean', label: 'Published')
      content_type.entries_custom_fields.build(name: 'published_at', type: 'date_time', label: 'Published at')
      content_type.entries_custom_fields.build(name: 'rating', type: 'integer', label: 'Rating')
      content_type.entries_custom_fields.build(name: 'price', type: 'float', label: 'Price')
      content_type.entries_custom_fields.build(name: 'tags', type: 'tags', label: 'Tags')
      content_type.entries_custom_fields.build(name: 'banner_asset_url', type: 'string', label: 'Banner URL')
      content_type.entries_custom_fields.build(name: 'category', type: 'select', label: 'Category').tap do |field|
        field.select_options.build name: 'Development', position: 0
        field.select_options.build name: 'Design', position: 1
      end      

      allow(content_type).to receive(:site).and_return(site)

      content_type.save!
    end.reload
  end

  def create_authors_content_type
    build(:content_type, site: site, name: 'Authors').tap do |content_type|
      content_type.entries_custom_fields.build(name: 'name', type: 'string', label: 'Name')
      content_type.save!
    end.reload
  end

  def create_content_type_relationships
    articles_klass = content_type.klass_with_custom_fields(:entries).name
    authors_klass = authors_content_type.klass_with_custom_fields(:entries).name
    
    content_type.entries_custom_fields.build(label: 'Author', type: 'belongs_to', class_name: authors_klass, inverse_of: :articles)
    content_type.entries_custom_fields.build(label: 'Reviewers', type: 'many_to_many', class_name: authors_klass, inverse_of: :reviewed_articles)
    content_type.save      

    authors_content_type.entries_custom_fields.build(
      label: 'Articles', 
      type: 'has_many', 
      class_name: articles_klass, 
      inverse_of: :author
    )
    authors_content_type.entries_custom_fields.build(
      label: 'Reviewed articles', 
      name: 'reviewed_articles',
      type: 'many_to_many', 
      class_name: articles_klass, 
      inverse_of: :reviewers
    )
    authors_content_type.save
  end
end