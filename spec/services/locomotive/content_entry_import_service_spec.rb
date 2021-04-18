# encoding: utf-8

describe Locomotive::ContentEntryImportService do

  let(:site)                  { create('test site') }
  let(:account)               { create(:account) }
  let(:content_type)          { create_content_type }
  let(:authors_content_type)  { create_authors_content_type }
  let(:locale)                { :en }
  let(:service)               { described_class.new(content_type, account, locale) }
  let(:csv_asset)             { create(:asset, site: site, source: FixturedAsset.open('articles.csv')) }

  describe '#import!' do

    context 'the CSV file is bogus' do
      let(:csv_asset) { create(:asset, site: site, source: FixturedAsset.open('5k.png')) }
      
      it 'cancels the import' do
        expect(content_type).to receive(:cancel_import).with('foo bar')
        subject { service.import(csv_asset.id, {}) }  
      end
    end

    context 'the CSV file is valid' do  
      it 'updates the state of the import' do
        expect(content_type.import_status).to eq nil
        expect(content_type).to receive(:start_import).once
        expect(content_type).to receive(:finish_import).once
        expect(service).to receive(:import_rows).and_return([:ok, { created: 1, updated: 0, failed: [] }])
        service.import('asset-42', {})
      end
    end
  end

  describe '#import' do
    before do
      create_content_type_relationships
      site.content_assets.create(filename: 'mybanner.png', source: FixturedAsset.open('5k.png'))
      content_type.entries.create(_slug: 'first-article', title: 'First article')
      content_type.entries.create(_slug: 'lorem-ipsum', title: 'Second article')
      authors_content_type.entries.create!(name: 'John Doe', _slug: 'john-doe')
      authors_content_type.entries.create!(name: 'Jane Doe', _slug: 'jane-doe')
    end

    let(:csv_options) { {} }
    subject { service.import(csv_asset.id, csv_options) }

    it 'creates as many articles as there are rows in the CSV' do
      expect { 
        is_expected.to eq([:ok, { created: 1, updated: 2, failed: [3] }])
      }.to change(content_type.entries, :count).by(1)
      entry = content_type.entries.first.reload
      expect(entry.title).to eq 'Hello world'
      expect(entry.banner_asset_url).to match /\/sites\/[^\/]+\/assets\/[^\/]+\/5k.png$/
      expect(entry.category).to eq 'Development'
      expect(entry.author.name).to eq 'John Doe'
      expect(entry.reviewers.pluck(:name)).to eq(['John Doe', 'Jane Doe'])
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