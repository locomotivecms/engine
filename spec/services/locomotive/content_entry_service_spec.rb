# coding: utf-8

require 'spec_helper'

describe Locomotive::ContentEntryService do

  let(:site)          { FactoryGirl.create('test site') }
  let(:content_type)  { create_content_type }
  let(:service)       { Locomotive::ContentEntryService.new(content_type) }

  describe '#all' do

    let(:options) { {} }
    subject { service.all(options) }

    before {
      create_content_entry(title: 'Hello world', body: 'Lorem ipsum', published: true)
      create_content_entry(title: 'Bla bla', body: 'Lorem ipsum', published: false)
    }

    context 'no options' do
      its(:count) { should eq 2 }
    end

    context 'search for a title' do
      let(:options) { { q: 'llo' } }
      its(:count) { should eq 1 }
    end

    context 'search for published articles' do
      let(:options) { { where: '{"published":true}' } }
      its(:count) { should eq 1 }
    end

  end

  describe '#prepare_where_statement' do

    let(:options) { {} }
    subject { service.send(:prepare_where_statement, options) }

    context 'no options' do
      it { subject.should eq({}) }
    end

    context 'with q option' do
      let(:options) { { q: 'Lorem ipsum' } }
      it { subject.should eq({ "title" => /.*Lorem.*ipsum.*/i }) }

      context 'the content type has some filter fields' do
        before { add_filter_fields('Title', 'Body') }
        it { subject.should eq({ "$or" => [{ "title" => /.*Lorem.*ipsum.*/i }, { "body" => /.*Lorem.*ipsum.*/i }] }) }
      end
    end

    context 'with the where option (JSON)' do

      context 'empty JSON' do
        let(:options) { { where: '' } }
        it { subject.should eq({}) }
      end

      context 'a simple JSON' do
        let(:options) { { where: '{"published":true}' } }
        it { subject.should eq({ "published" => true }) }
      end

    end

    context 'with the where option (Hash)' do
      let(:options) { { where: { published: true } } }
      it { subject.should eq({ "published" => true }) }
    end

    context 'using both the q and where keys' do
      let(:options) { { q: 'Lorem ipsum', where: '{"published":true}' } }
      it { subject.should eq({ "title" => /.*Lorem.*ipsum.*/i, "published" => true }) }
    end

  end

  describe '#prepare_options_for_all' do

    let(:options) { { page: 1, q: 'o', where: '{"published":true}' } }
    subject { service.send(:prepare_options_for_all, options) }

    it { subject.should eq({ page: 1, per_page: 10, where: { "title" => /.*o.*/i, "published" => true }, grouping: false }) }

  end

  describe '#destroy_all' do

    subject { service.destroy_all }

    before {
      create_content_entry(title: 'Hello world', body: 'Lorem ipsum', published: true)
      create_content_entry(title: 'Bla bla', body: 'Lorem ipsum', published: false)
    }

    it { should eq 2 }
    it { subject; content_type.entries.count.should eq 0 }

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
