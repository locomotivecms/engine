# encoding: utf-8

describe Locomotive::EditorService do

  let(:account)     { double(:account) }
  let(:page)        { double(:page) }
  let(:locale)      { :en }
  let(:service)     { described_class.new(site, account, page, locale) }

  describe '#find_resources' do

    let(:site)  { create(:site) }
    let(:type)  { nil }
    let(:query) { 'none' }
    let(:scope) { nil }

    subject { service.find_resources(type, query, scope) }

    it { is_expected.to eq [] }

    context 'querying pages' do

      before do
        create(:page, title: 'Hello', slug: nil, site: site, published: false)
        create(:page, title: 'Hello layout', slug: nil, site: site, is_layout: true)
        2.times { |i| create(:page, title: "Hello world #{i}", slug: nil, site: site) }
        3.times { |i| create(:page, title: "Another page #{i}", slug: nil, site: site) }
      end

      let(:type)  { 'page' }
      let(:query) { 'Hello' }

      it 'returns the pages whose titles match the query' do
        expect(subject.count).to eq 3
        expect(subject.first[:type]).to eq('page')
        expect(subject.first[:label][0]).to eq('Page')
        expect(subject.first[:label][1]).to eq('Hello')
      end

    end

    context 'querying content entries' do

      let(:content_type)  { create(:content_type, :article, site: site) }
      let(:type)          { 'content_entry' }
      let(:query)         { 'Article' }
      let(:scope)         { 'articles' }

      before do
        klass_name = content_type.entries_class_name
        create(:page, title: 'Article template', slug: nil, site: site, target_klass_name: klass_name)
        content_type.entries.create(title: "Article", visible: false)
        3.times { |i| content_type.entries.create(title: "Article #{i}", visible: true) }
      end

      it 'returns the articles whose titles match the query' do
        expect(subject.count).to eq 3
        expect(subject.first[:type]).to eq('content_entry')
        expect(subject.first[:label][0]).to eq('Articles')
        expect(subject.first[:label][1]).to eq('Article 0')
      end

    end

  end

  describe '#save' do

    let(:site)        { double(:site) }
    let(:activities)  { double(:activities) }

    let(:site_attributes) { {
      sections_content:
      <<-JSON
        {
          "header_01": {
            "settings": {},
            "blocks": [
              {
                "type": "menu_item",
                "id": "0"
              },
              {
                "type": "menu_item",
                "id": "1"
              },
              {
                "type": "menu_item",
                "id": "2"
              }
            ]
          }
        }
      JSON
      }
    }

    let(:page_attributes) { {
      sections_dropzone_content:
        <<-JSON
          [{
            "id": "10ebe2f8-af88-4d87-9df8-58e3e624d662",
            "name": "Cover 04",
            "settings": {},
            "blocks": [
              {
                "type": "slide",
                "id": "72a28230-62fb-429c-b7ae-69ae377015b8"
              },
              {
                "type": "slide",
                "id": "bc06c67a-d268-44fb-a6de-cff5df845ed7"
              }
            ]
          }]
        JSON
    } }

    subject { service.save(site_attributes, page_attributes) }

    it 'save the page sections dropzone' do
      allow(site).to receive(:title) { 'aTitle' }
      allow(activities).to receive(:create!) { true }
      allow(site).to receive(:activities) { activities }
      allow(page).to receive(:title) { 'aTitle' }
      allow(page).to receive(:_id) { 'anId' }

      expect(site).to receive(:update_attributes).with({
        sections_content: {
          'header_01' => {
            'settings' => {},
            'blocks' => [{ 'type' => 'menu_item' }, { 'type' => 'menu_item' }, { 'type' => 'menu_item' }]
          }
        }
      }).and_return(true)

      expect(page).to receive(:update_attributes).with({
        sections_dropzone_content: [
          { 'name' => 'Cover 04', 'settings' => {}, 'blocks' => [{ 'type' => 'slide' }, { 'type' => 'slide' }] }
        ],
        sections_content: nil
      }).and_return(true)

      subject
    end

  end
end
