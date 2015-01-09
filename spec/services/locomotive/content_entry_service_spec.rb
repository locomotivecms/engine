# coding: utf-8

require 'spec_helper'

describe Locomotive::ContentEntryService do

  let(:site)          { create('test site') }
  let(:account)       { create(:account) }
  let(:content_type)  { create_content_type }
  let(:service)       { Locomotive::ContentEntryService.new(content_type, account) }

  describe '#all' do

    let(:options) { {} }
    subject { service.all(options) }

    before {
      create_content_entry(title: 'Hello world', body: 'Lorem ipsum', published: true)
      create_content_entry(title: 'Bla bla', body: 'Lorem ipsum', published: false)
    }

    context 'no options' do
      it { expect(subject.count).to eq(2) }
    end

    context 'search for a title' do
      let(:options) { { q: 'llo' } }
      it { expect(subject.count).to eq(1) }
    end

    context 'search for published articles' do
      let(:options) { { where: '{"published":true}' } }
      it { expect(subject.count).to eq(1) }
    end

  end

  describe '#prepare_where_statement' do

    let(:options) { {} }
    subject { service.send(:prepare_where_statement, options) }

    context 'no options' do
      it { is_expected.to eq({}) }
    end

    context 'with q option' do
      let(:options) { { q: 'Lorem ipsum' } }
      it { is_expected.to eq({ "title" => /.*Lorem.*ipsum.*/i }) }

      context 'the content type has some filter fields' do
        before { add_filter_fields('Title', 'Body') }
        it { is_expected.to eq({ "$or" => [{ "title" => /.*Lorem.*ipsum.*/i }, { "body" => /.*Lorem.*ipsum.*/i }] }) }
      end
    end

    context 'with the where option (JSON)' do

      context 'empty JSON' do
        let(:options) { { where: '' } }
        it { is_expected.to eq({}) }
      end

      context 'a simple JSON' do
        let(:options) { { where: '{"published":true}' } }
        it { is_expected.to eq({ "published" => true }) }
      end

    end

    context 'with the where option (Hash)' do
      let(:options) { { where: { published: true } } }
      it { is_expected.to eq({ "published" => true }) }
    end

    context 'using both the q and where keys' do
      let(:options) { { q: 'Lorem ipsum', where: '{"published":true}' } }
      it { is_expected.to eq({ "title" => /.*Lorem.*ipsum.*/i, "published" => true }) }
    end

  end

  describe '#prepare_options_for_all' do

    let(:options) { { page: 1, q: 'o', where: '{"published":true}' } }
    subject { service.send(:prepare_options_for_all, options) }

    it { is_expected.to eq({ page: 1, per_page: 10, where: { "title" => /.*o.*/i, "published" => true } }) }

  end

  describe '#destroy_all' do

    subject { service.destroy_all }

    before {
      create_content_entry(title: 'Hello world', body: 'Lorem ipsum', published: true)
      create_content_entry(title: 'Bla bla', body: 'Lorem ipsum', published: false)
    }

    it { is_expected.to eq 2 }
    it { subject; expect(content_type.entries.count).to eq 0 }

  end

  describe '#create' do

    let(:attributes) { { title: 'Hello world', body: 'Lorem ipsum', published: true } }

    subject { service.create(attributes) }

    it { expect(subject.created_by).to eq account }
    it { expect { subject }.to change { Locomotive::ContentEntry.count }.by(1) }

    context 'missing attributes' do

      let(:attributes) { {} }

      it { expect(subject.errors.blank?).to eq false }
      it { expect { subject }.to_not change { Locomotive::ContentEntry.count } }

    end

  end

  describe '#update' do

    let!(:entry) { create_content_entry(title: 'Hello world', body: 'Lorem ipsum', published: true) }
    let(:attributes) { { title: 'Goodbye' } }

    subject { service.update(entry, attributes) }

    it { expect(subject.title).to eq 'Goodbye' }
    it { expect(subject.updated_by).to eq account }

  end

  describe '#sort' do

    let(:sometime)    { Time.parse('2015/01/06 00:00:00') }
    let(:entry)       { create_content_entry(title: 'Goodbye', body: 'Lorem ipsum', published: true, _position: 0, updated_at: sometime) }
    let(:last_entry)  { create_content_entry(title: 'Hello world', body: 'Lorem ipsum', published: true, _position: 1, updated_at: sometime) }

    let(:attributes)  { [last_entry._id.to_s, entry._id.to_s] }

    before { service.sort(attributes) }

    subject { content_type.ordered_entries }

    it { expect(subject.pluck(:title)).to eq ['Hello world', 'Goodbye'] }
    it { expect(subject.pluck(:updated_at)).to eq [sometime, sometime] }

  end

  describe '#permitted_attributes' do

    subject { service.permitted_attributes }

    it { is_expected.to eq %w(_slug _position _visible seo_title meta_keywords meta_description title body published) }

  end

  def create_content_type
    FactoryGirl.build(:content_type, site: site, name: 'Articles').tap do |content_type|
      content_type.entries_custom_fields.build(name: 'title', type: 'string', label: 'Title')
      content_type.entries_custom_fields.build(name: 'body', type: 'text', label: 'Body')
      content_type.entries_custom_fields.build(name: 'published', type: 'boolean', label: 'Published')
      content_type.save!
    end
  end

  def add_filter_fields(*labels)
    content_type.filter_fields = []
    labels.each do |label|
      field = content_type.entries_custom_fields.where(label: label).first
      content_type.filter_fields << field._id
    end
  end

  def create_content_entry(attributes)
    content_type.entries.create!(attributes)
  end

end
