# coding: utf-8

require 'spec_helper'

describe Locomotive::ContentEntryService do

  let(:site)          { create('test site') }
  let(:account)       { create(:account) }
  let(:content_type)  { create_content_type }
  let(:service)       { described_class.new(content_type, account) }

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

    context 'no pagination asked' do

      let(:options) { { page: 1, q: 'o', where: '{"published":true}', no_pagination: true } }

      it { is_expected.to eq({ where: { "title" => /.*o.*/i, "published" => true } }) }

    end

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

    let(:content_type)  { create_content_type(order_by: '_position') }
    let(:sometime)      { Time.parse('2015/01/06 00:00:00') }
    let!(:entry)        { create_content_entry(title: 'Goodbye', body: 'Lorem ipsum', published: true, _position: 0, updated_at: sometime) }
    let!(:last_entry)   { create_content_entry(title: 'Hello world', body: 'Lorem ipsum', published: true, _position: 1, updated_at: sometime) }

    let(:attributes)  { [last_entry._id.to_s, entry._id.to_s] }

    subject { service.sort(attributes); content_type.ordered_entries }

    it { expect(subject.pluck(:title)).to eq [{ "en" => "Hello world" }, { "en" => "Goodbye" }] }
    it { expect(subject.pluck(:updated_at)).to eq [sometime, sometime] }
    it { expect { subject }.to change { site.reload.content_version } }

  end

  describe '#permitted_attributes' do

    subject { service.permitted_attributes }

    it { is_expected.to eq %w(_slug _position _visible seo_title meta_keywords meta_description title body published) }

  end

  describe '#localize' do

    let(:new_locales)   { ['fr'] }
    let(:previous_default_locale) { nil }
    let!(:entry_1) { create_content_entry(title: 'Hello world', body: 'Lorem ipsum', published: true) }
    let!(:entry_2) { create_content_entry(title: 'Bla bla', body: 'Lorem ipsum', published: false) }

    before { service.localize(new_locales, previous_default_locale) }

    it 'sets the slug in the new locale' do
      expect(entry_1.reload._slug_translations).to eq('en' => 'hello-world', 'fr' => 'hello-world')
      expect(entry_2.reload._slug_translations).to eq('en' => 'bla-bla', 'fr' => 'bla-bla')
    end

  end

  describe '#public_create' do

    let(:attributes) { { title: 'Hello world', body: 'Lorem ipsum' } }

    subject { service.public_create(attributes) }

    it { expect { subject }.to change { content_type.entries.count } }
    it { expect(service).to receive(:send_notifications); subject }

    context 'invalid' do

      let(:attributes) { {} }

      it { expect { subject }.not_to change { content_type.entries.count } }
      it { expect(service).not_to receive(:send_notifications); subject }

    end

  end

  describe '#send_notifications' do

    let(:enabled)       { true }
    let(:account_1)     { create(:designer, site: site).account }
    let(:account_2)     { create('brazillian user') }
    let(:content_type)  { create_content_type(public_submission_enabled: enabled, public_submission_accounts: ['', account_1._id, account_2._id]) }
    let(:entry)         { create_content_entry(title: 'Shoot an email', body: 'now') }

    subject { service.send_notifications(entry) }

    context 'public_submission disabled' do

      let(:enabled) { false }

      it { expect(Locomotive::Notifications).not_to receive(:new_content_entry); subject }

    end

    context 'public_submission enabled' do

      it 'sends email notifications only to the members of the site' do
        expect(Locomotive::Notifications).to receive(:new_content_entry).with(account_1, entry).and_return(instance_double('mailer', deliver: true))
        expect(Locomotive::Notifications).not_to receive(:new_content_entry).with(account_2, entry)
        subject
      end

    end

  end

  def create_content_type(attributes = {})
    FactoryGirl.build(:content_type, site: site, name: 'Articles').tap do |content_type|
      content_type.entries_custom_fields.build(name: 'title', type: 'string', label: 'Title', localized: true)
      content_type.entries_custom_fields.build(name: 'body', type: 'text', label: 'Body', localized: true)
      content_type.entries_custom_fields.build(name: 'published', type: 'boolean', label: 'Published')

      content_type.attributes = attributes

      content_type.save!
    end.reload
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
