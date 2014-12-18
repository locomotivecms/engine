# encoding: utf-8

require 'spec_helper'

describe Locomotive::ContentEntry do

  before(:each) do
    Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true)
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
      Locomotive::Site.any_instance.stubs(:locales).returns(%w(en fr ru))
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

    describe '.slug' do

      it 'is not nil in the default locale' do
        ::Mongoid::Fields::I18n.locale = 'en'
        expect(@content_entry._slug).to eq('hello-world')
      end

      it 'is not translated by default in the other locale' do
        expect(@content_entry._slug).to eq(nil) # French
      end

    end

  end

  describe 'csv' do

    context 'entry itself' do

      subject { build_content_entry }

      it { should respond_to(:to_values) }

      describe '#to_values' do

        subject { build_content_entry.to_values(host: 'example.com') }

        it { expect(subject.size).to eq(6) }
        it { expect(subject.first).to eq('Locomotive') }
        it { expect(subject.last).to eq('July 05, 2013 00:00') }

        context 'with a file' do

          subject { build_content_entry(file: FixturedAsset.open('5k.png')).tap(&:save).to_values(host: 'example.com')[3] }

          it { should match(/^http:\/\/example.com\/sites\/[0-9a-f]+\/content_entry[0-9a-f]+\/[0-9a-f]+\/files\/5k.png$/) }

        end

      end

    end

    context 'set of entries' do

      before(:each) do
        @content_type.save
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

    it 'should find previous item when available' do
      expect(@second.previous.title).to eq('first')
      expect(@second.previous._position).to eq(0)
    end

    it 'should find next item when available' do
      expect(@second.next.title).to eq('third')
      expect(@second.next._position).to eq(2)
    end

    it 'should return nil when fetching previous item on first in list' do
      expect(@first.previous).to eq(nil)
    end

    it 'should return nil when fetching next item on last in list' do
      expect(@third.next).to eq(nil)
    end

    context "ordered by published at" do

      before do
        @content_type.update_attributes order_by: 'published_at', order_direction: 'asc'

        @very_first = build_content_entry(title: 'very first', _position: 4, published_at: Time.now, visible: true)
        @very_first.save!
      end

      it "should find previous item" do
        expect(@second.previous.title).to eq('third')
      end

      it "should find next item" do
        expect(@first.next.title).to eq('very first')
      end

      it 'should return nil when fetching previous item on first in list' do
        expect(@third.previous).to eq(nil)
      end

      it 'should return nil when fetching next item on last in list' do
        expect(@very_first.next).to eq(nil)
      end

      context 'with desc direction' do

        before do
          @content_type.update_attribute :order_direction, 'desc'
        end

        it "should find previous item" do
          expect(@second.previous.title).to eq('first')
        end

        it "should find next item" do
          expect(@first.next.title).to eq('second')
        end

        it 'should return nil when fetching previous item on first in list' do
          expect(@very_first.previous).to eq(nil)
        end

        it 'should return nil when fetching next item on last in list' do
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
      @content_entry.stubs(:_label_field_name).returns('file')
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

    it 'has a label based on the value of the first field' do
      expect(build_content_entry._label).to eq('Locomotive')
    end

    it 'uses the to_label method if the value of the label field defined it' do
      entry = build_content_entry(_label_field_name: 'with_to_label')
      entry.stubs(:with_to_label).returns(mock('with_to_label', to_label: 'acme'))
      expect(entry._label).to eq('acme')
    end

    it 'uses the to_s method at last if the label field did not define the to_label method' do
      entry = build_content_entry(_label_field_name: 'not_a_string')
      entry.stubs(:not_a_string).returns(mock('not_a_string', to_s: 'not_a_string'))
      expect(entry._label).to eq('not_a_string')
    end

  end

  describe '#file' do

    let(:entry) { build_content_entry(title: 'Hello world', file: FixturedAsset.open('5k.png')) }

    it 'writes the file to the filesystem' do
      entry.save
      expect(entry.file.url).to_not match(/content_content_entry/)
    end

  end

  describe '#public_submission' do

    before(:each) do
      @account_1 = FactoryGirl.build('admin user', id: fake_bson_id('1'))
      @account_2 = FactoryGirl.build('frenchy user', id: fake_bson_id('2'))

      @content_type.public_submission_enabled = true
      @content_type.public_submission_accounts = ['', @account_1._id, @account_2._id.to_s]

      site = FactoryGirl.build(:site)
      site.stubs(:accounts).returns([@account_1, @account_2])

      @content_entry = build_content_entry(site: site)
    end

    it 'does not send email notifications if the api is disabled' do
      @content_type.public_submission_enabled = false
      Locomotive::Notifications.expects(:new_content_entry).never
      @content_entry.save
    end

    it 'does not send email notifications if no api accounts' do
      @content_type.public_submission_accounts = nil
      Locomotive::Notifications.expects(:new_content_entry).never
      @content_entry.save
    end

    it 'sends email notifications when a new instance is created' do
      Locomotive::Notifications.expects(:new_content_entry).with(@account_1, @content_entry).returns(mock('mailer', deliver: true))
      Locomotive::Notifications.expects(:new_content_entry).with(@account_2, @content_entry).returns(mock('mailer', deliver: true))
      @content_entry.save
    end

  end

  describe '#site' do

    it 'assigns a site when saving the content entry' do
      content_entry = build_content_entry
      content_entry.save
      expect(content_entry.site).to_not eq(nil)
    end

  end

  def localize_content_type(content_type)
    content_type.entries_custom_fields.first.localized = true
    content_type.save
  end

  def build_content_entry(options = {})
    @content_type.entries.build({ title: 'Locomotive', description: 'Lorem ipsum....', _label_field_name: 'title', created_at: Time.zone.parse('2013-07-05 00:00:00') }.merge(options))
  end

  def fake_bson_id(id)
    BSON::ObjectId.from_string(id.to_s.rjust(24, '0'))
  end
end
