# encoding: utf-8

require 'spec_helper'

describe Locomotive::ContentEntry do

  before(:each) do
    allow_any_instance_of(Locomotive::Site).to receive(:create_default_pages!).and_return(true)
    @content_type = FactoryGirl.build(:content_type)
    @content_type.entries_custom_fields.build label: 'Title', type: 'string'
    @content_type.entries_custom_fields.build label: 'Description', type: 'text'
    @content_type.entries_custom_fields.build label: 'Visible ?', type: 'boolean', name: 'visible'
    @content_type.entries_custom_fields.build label: 'File', type: 'file'
    @content_type.entries_custom_fields.build label: 'Published at', type: 'date'
    @content_type.valid?
    @content_type.send(:set_label_field)
  end

  describe '#validation' do

    it 'is valid' do
      expect(build_content_entry).to be_valid
    end

    ## Validations ##

    it 'requires the presence of title' do
      content_entry = build_content_entry title: nil
      expect(content_entry).to_not be_valid
      expect(content_entry.errors[:title]).to eq(["can't be blank"])
    end

    it 'requires the presence of the permalink (_slug)' do
      content_entry = build_content_entry title: nil
      expect(content_entry).to_not be_valid
      expect(content_entry.errors[:_slug]).to eq(["can't be blank"])
    end

  end

  describe '.slug' do

    before :each do
      build_content_entry(_slug: 'dogs').tap do |entry|
        entry.save!
        expect(entry._slug).to eq('dogs')
      end
    end

    it 'accepts underscore instead of dashes' do
      expect(build_content_entry(_slug: 'monkey_wrench').tap(&:save!)._slug).to eq('monkey_wrench')
    end

    it 'uses the given slug if it is unique' do
      expect(build_content_entry(_slug: 'monkeys').tap(&:save!)._slug).to eq('monkeys')
      expect(build_content_entry(_slug: 'cats-2').tap(&:save!)._slug).to eq('cats-2')
    end

    it 'appends a number to the end of the slug if it is not unique' do
      expect(build_content_entry(_slug: 'dogs').tap(&:save!)._slug).to eq('dogs-1')
      expect(build_content_entry(_slug: 'dogs').tap(&:save!)._slug).to eq('dogs-2')
      expect(build_content_entry(_slug: 'dogs-2').tap(&:save!)._slug).to eq('dogs-3')
      expect(build_content_entry(_slug: 'dogs-2').tap(&:save!)._slug).to eq('dogs-4')
    end

    it 'ignores the case of a slug' do
      expect(build_content_entry(_slug: 'dogs').tap(&:save!)._slug).to eq('dogs-1')
      expect(build_content_entry(_slug: 'DOGS').tap(&:save!)._slug).to eq('dogs-2')
    end

    it 'correctly handles slugs with multiple numbers' do
      expect(build_content_entry(_slug: 'fish-1-2').tap(&:save!)._slug).to eq('fish-1-2')
      expect(build_content_entry(_slug: 'fish-1-2').tap(&:save!)._slug).to eq('fish-1-3')

      expect(build_content_entry(_slug: 'fish-1-hi').tap(&:save!)._slug).to eq('fish-1-hi')
      expect(build_content_entry(_slug: 'fish-1-hi').tap(&:save!)._slug).to eq('fish-1-hi-1')
    end

    it 'correctly handles more than 13 slugs with the same name' do
      (1..15).each do |i|
        expect(build_content_entry(_slug: 'dogs').tap(&:save!)._slug).to eq("dogs-#{i}")
      end
    end

    it 'copies the slug in ALL the locales of the site' do
      allow_any_instance_of(Locomotive::Site).to receive(:locales).and_return(%w(en fr ru))
      entry = build_content_entry(_slug: 'monkeys').tap(&:save!)
      expect(entry._slug_translations).to eq({ 'en' => 'monkeys', 'fr' => 'monkeys', 'ru' => 'monkeys' })
    end
  end

  describe '#I18n' do

    before(:each) do
      localize_content_type @content_type
      ::Mongoid::Fields::I18n.locale = 'en'
      @content_entry = build_content_entry(title: 'Hello world')
      @content_entry.send(:set_slug)
      ::Mongoid::Fields::I18n.locale = 'fr'
    end

    after(:all) do
      ::Mongoid::Fields::I18n.locale = 'en'
    end

    it 'tells if an entry has been translated or not' do
      expect(@content_entry.translated?).to eq(false)
      @content_entry.title = 'Bonjour'
      expect(@content_entry.translated?).to eq(true)
    end

    describe '#slug' do

      it 'is not nil in the default locale' do
        ::Mongoid::Fields::I18n.locale = 'en'
        expect(@content_entry._slug).to eq('hello-world')
      end

      it 'is not translated by default in the other locale' do
        expect(@content_entry._slug).to eq(nil) # French
      end

      it 'is translated in all the locales when being created' do
        @content_entry.site.locales = %w(en fr)
        ::Mongoid::Fields::I18n.locale = 'en'
        @content_entry.send(:localize_slug)
        ::Mongoid::Fields::I18n.locale = 'fr'
        expect(@content_entry._slug).to eq('hello-world') # French
      end

    end

  end

  describe 'csv' do

    context 'entry itself' do

      subject { build_content_entry }

      it { is_expected.to respond_to(:to_values) }

      describe '#to_values' do

        subject { build_content_entry.to_values(host: 'example.com') }

        it { expect(subject.size).to eq(6) }
        it { expect(subject.first).to eq('Locomotive') }
        it { expect(subject.last).to eq('July 05, 2013 00:00') }

        context 'with a file' do

          subject { build_content_entry(file: FixturedAsset.open('5k.png')).tap(&:save).to_values(host: 'example.com')[3] }

          it { is_expected.to match(/^http:\/\/example.com\/sites\/[0-9a-f]+\/content_entry[0-9a-f]+\/[0-9a-f]+\/files\/5k.png$/) }

        end

      end

    end

    context 'set of entries' do

      before(:each) do
        @content_type.save!
        3.times { build_content_entry(file: FixturedAsset.open('5k.png')).save! }
      end

      subject { @content_type.ordered_entries.to_csv(host: 'example.com').split("\n") }

      it { expect(subject.size).to eq(4) }
      it { expect(subject.first).to eq("Title,Description,Visible ?,File,Published at,Created at") }
      it { expect(subject.last).to match(/^Locomotive,Lorem ipsum....,false,http:\/\/example.com\/sites\/[0-9a-f]+\/content_entry[0-9a-f]+\/[0-9a-f]+\/files\/5k.png,\"\",\"July 05, 2013 00:00\"$/) }

    end

  end

  describe "#navigation" do

    before(:each) do
      @content_type.update_attribute :order_by, '_position'

      %w(first second third).each_with_index do |item, index|
        content = build_content_entry(title: item.to_s, _position: index, published_at: (index + 2).days.ago, visible: true)
        content.save!
        instance_variable_set "@#{item}", content
      end
    end

    it 'finds previous item when available' do
      expect(@second.previous.title).to eq('first')
      expect(@second.previous._position).to eq(0)
    end

    it 'finds next item when available' do
      expect(@second.next.title).to eq('third')
      expect(@second.next._position).to eq(2)
    end

    it 'returns nil when fetching previous item on first in list' do
      expect(@first.previous).to eq(nil)
    end

    it 'returns nil when fetching next item on last in list' do
      expect(@third.next).to eq(nil)
    end

    context "ordered by published at" do

      before do
        @content_type.update_attributes order_by: 'published_at', order_direction: 'asc'

        @very_first = build_content_entry(title: 'very first', _position: 4, published_at: Time.now, visible: true)
        @very_first.save!
      end

      it "finds previous item" do
        expect(@second.previous.title).to eq('third')
      end

      it "finds next item" do
        expect(@first.next.title).to eq('very first')
      end

      it 'returns nil when fetching previous item on first in list' do
        expect(@third.previous).to eq(nil)
      end

      it 'returns nil when fetching next item on last in list' do
        expect(@very_first.next).to eq(nil)
      end

      context 'with desc direction' do

        before do
          @content_type.update_attribute :order_direction, 'desc'
        end

        it "finds previous item" do
          expect(@second.previous.title).to eq('first')
        end

        it "finds next item" do
          expect(@first.next.title).to eq('second')
        end

        it 'returns nil when fetching previous item on first in list' do
          expect(@very_first.previous).to eq(nil)
        end

        it 'returns nil when fetching next item on last in list' do
          expect(@third.next).to eq(nil)
        end

      end

    end
  end

  describe '#permalink' do

    before(:each) do
      @content_entry = build_content_entry
    end

    it 'has a default value based on the highlighted field' do
      @content_entry.send(:set_slug)
      expect(@content_entry._permalink).to eq('locomotive')
    end

    it 'is empty if no value for the highlighted field is provided' do
      @content_entry.title = nil; @content_entry.send(:set_slug)
      expect(@content_entry._permalink).to eq(nil)
    end

    it 'includes dashes instead of white spaces' do
      @content_entry.title = 'my content instance'; @content_entry.send(:set_slug)
      expect(@content_entry._permalink).to eq('my-content-instance')
    end

    it 'removes accentued characters' do
      @content_entry.title = "une chèvre dans le pré"; @content_entry.send(:set_slug)
      expect(@content_entry._permalink).to eq('une-chevre-dans-le-pre')
    end

    it 'removes dots' do
      @content_entry.title = "my.test"; @content_entry.send(:set_slug)
      expect(@content_entry._permalink).to eq('my-dot-test')
    end

    it 'accepts non-latin chars' do
      @content_entry.title = "абракадабра"; @content_entry.send(:set_slug)
      expect(@content_entry._permalink).to eq('abrakadabra')
    end

    it 'also accepts a file field as the highlighted field' do
      allow(@content_entry).to receive(:_label_field_name).and_return('file')
      @content_entry.file = FixturedAsset.open('5k.png'); @content_entry.send(:set_slug)
      expect(@content_entry._permalink).to eq('5k')
    end

  end

  describe '#visibility' do

    before(:each) do
      @content_entry = build_content_entry
    end

    it 'is not visible by default' do
      @content_entry.send(:set_visibility)
      expect(@content_entry.visible?).to eq(false)
    end

    it 'can be visible even if it is nil' do
      @content_entry.visible = nil
      @content_entry.send(:set_visibility)
      expect(@content_entry.visible?).to eq(true)
    end

    it 'can not be visible' do
      @content_entry.visible = false
      @content_entry.send(:set_visibility)
      expect(@content_entry.visible?).to eq(false)
    end

  end

  describe '#label' do

    let(:entry) { build_content_entry }

    it 'has a label based on the value of the first field' do
      expect(build_content_entry._label).to eq('Locomotive')
    end

    it 'uses the to_label method if the value of the label field defined it' do
      allow(entry).to receive(:_label_field_name).and_return(:with_to_label)
      allow(entry).to receive(:with_to_label).and_return(instance_double('with_to_label', to_label: 'acme'))
      expect(entry._label).to eq('acme')
    end

    it 'uses the to_s method at last if the label field did not define the to_label method' do
      allow(entry).to receive(:_label_field_name).and_return(:not_a_string)
      allow(entry).to receive(:not_a_string).and_return(instance_double('not_a_string', to_s: 'not_a_string'))
      expect(entry._label).to eq('not_a_string')
    end

  end

  describe '#file' do

    let(:entry) { build_content_entry(title: 'Hello world', file: FixturedAsset.open('5k.png')) }

    it 'writes the file to the filesystem' do
      entry.save
      expect(entry.file.url).to_not match(/content_content_entry/)
    end

    it 'using base64 string to replace a file' do
      entry.file = nil
      entry.remote_file_url = "data:image/jpeg;jobs.jpeg;base64,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"
      entry.save
      expect(entry.file.url).to match(/\/files\/jobs\.jpeg\Z/)
    end

  end

  describe '#site' do

    it 'assigns a site when saving the content entry' do
      content_entry = build_content_entry
      content_entry.save
      expect(content_entry.site).to_not eq(nil)
    end

  end

  describe '#to_liquid' do

    let(:entry) { build_content_entry }

    subject { entry.to_liquid }

    it { expect(subject._label).to eq 'Locomotive' }

  end

  # it_should_behave_like 'model scoped by a site' do

  #   let(:model)         { build_content_entry }
  #   let(:attribute)     { :content_version }

  # end

  def localize_content_type(content_type)
    content_type.entries_custom_fields.first.localized = true
    content_type.save
  end

  def build_content_entry(options = {})
    @content_type.entries.build({ title: 'Locomotive', description: 'Lorem ipsum....', _label_field_name: 'title', created_at: Time.zone.parse('2013-07-05 00:00:00') }.merge(options)).tap do |entry|
      entry.send(:set_site)
    end
  end

  def fake_bson_id(id)
    BSON::ObjectId.from_string(id.to_s.rjust(24, '0'))
  end
end
