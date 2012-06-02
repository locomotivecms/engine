# encoding: utf-8

require 'spec_helper'

describe Locomotive::ContentEntry do

  before(:each) do
    Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true)
    @content_type = FactoryGirl.build(:content_type)
    @content_type.entries_custom_fields.build :label => 'Title', :type => 'string'
    @content_type.entries_custom_fields.build :label => 'Description', :type => 'text'
    @content_type.entries_custom_fields.build :label => 'Visible ?', :type => 'boolean', :name => 'visible'
    @content_type.entries_custom_fields.build :label => 'File', :type => 'file'
    @content_type.valid?
    @content_type.send(:set_label_field)
  end

  describe '#validation' do

    it 'is valid' do
      build_content_entry.should be_valid
    end

    ## Validations ##

    it 'requires the presence of title' do
      content_entry = build_content_entry :title => nil
      content_entry.should_not be_valid
      content_entry.errors[:title].should == ["can't be blank"]
    end

    it 'requires the presence of the permalink (_slug)' do
      content_entry = build_content_entry :title => nil
      content_entry.should_not be_valid
      content_entry.errors[:_slug].should == ["can't be blank"]
    end

  end

  context 'setting the slug' do
    before :each do
      build_content_entry(:_slug => 'dogs').tap(&:save!)._slug.should == 'dogs'
    end

    it 'uses the given slug if it is unique' do
      build_content_entry(:_slug => 'monkeys').tap(&:save!)._slug.should == 'monkeys'
      build_content_entry(:_slug => 'cats-2').tap(&:save!)._slug.should == 'cats-2'
    end

    it 'appends a number to the end of the slug if it is not unique' do
      build_content_entry(:_slug => 'dogs').tap(&:save!)._slug.should == 'dogs-1'
      build_content_entry(:_slug => 'dogs').tap(&:save!)._slug.should == 'dogs-2'
      build_content_entry(:_slug => 'dogs-2').tap(&:save!)._slug.should == 'dogs-3'
      build_content_entry(:_slug => 'dogs-2').tap(&:save!)._slug.should == 'dogs-4'
    end

    it 'ignores the case of a slug' do
      build_content_entry(:_slug => 'dogs').tap(&:save!)._slug.should == 'dogs-1'
      build_content_entry(:_slug => 'DOGS').tap(&:save!)._slug.should == 'dogs-2'
    end

    it 'correctly handles slugs with multiple numbers' do
      build_content_entry(:_slug => 'fish-1-2').tap(&:save!)._slug.should == 'fish-1-2'
      build_content_entry(:_slug => 'fish-1-2').tap(&:save!)._slug.should == 'fish-1-3'

      build_content_entry(:_slug => 'fish-1-hi').tap(&:save!)._slug.should == 'fish-1-hi'
      build_content_entry(:_slug => 'fish-1-hi').tap(&:save!)._slug.should == 'fish-1-hi-1'
    end
  end

  context '#i18n' do

    before(:each) do
      localize_content_type @content_type
      ::Mongoid::Fields::I18n.locale = 'en'
      @content_entry = build_content_entry(:title => 'Hello world')
      ::Mongoid::Fields::I18n.locale = 'fr'
    end

    after(:all) do
      ::Mongoid::Fields::I18n.locale = 'en'
    end

    it 'tells if an entry has been translated or not' do
      @content_entry.translated?.should be_false
      @content_entry.title = 'Bonjour'
      @content_entry.translated?.should be_true
    end

  end

  describe "#navigation" do
    before(:each) do
      @content_type.save

      %w(first second third).each_with_index do |item, index|
        content = build_content_entry(:title => item.to_s, :_position => index)
        content.save
        instance_variable_set "@#{item}", content
      end
    end

    it 'should find previous item when available' do
      @second.previous.title.should == 'first'
      @second.previous._position.should == 1
    end

    it 'should find next item when available' do
      @second.next.title.should == 'third'
      @second.next._position.should == 3
    end

    it 'should return nil when fetching previous item on first in list' do
      @first.previous.should == nil
    end

    it 'should return nil when fetching next item on last in list' do
      @third.next.should == nil
    end
  end

  describe '#permalink' do

    before(:each) do
      @content_entry = build_content_entry
    end

    it 'has a default value based on the highlighted field' do
      @content_entry.send(:set_slug)
      @content_entry._permalink.should == 'locomotive'
    end

    it 'is empty if no value for the highlighted field is provided' do
      @content_entry.title = nil; @content_entry.send(:set_slug)
      @content_entry._permalink.should be_nil
    end

    it 'includes dashes instead of white spaces' do
      @content_entry.title = 'my content instance'; @content_entry.send(:set_slug)
      @content_entry._permalink.should == 'my-content-instance'
    end

    it 'removes accentued characters' do
      @content_entry.title = "une chèvre dans le pré"; @content_entry.send(:set_slug)
      @content_entry._permalink.should == 'une-chevre-dans-le-pre'
    end

    it 'removes dots' do
      @content_entry.title = "my.test"; @content_entry.send(:set_slug)
      @content_entry._permalink.should == 'my-test'
    end

    it 'accepts non-latin chars' do
      @content_entry.title = "абракадабра"; @content_entry.send(:set_slug)
      @content_entry._permalink.should == 'abrakadabra'
    end

    it 'also accepts a file field as the highlighted field' do
      @content_entry.stubs(:_label_field_name).returns('file')
      @content_entry.file = FixturedAsset.open('5k.png'); @content_entry.send(:set_slug)
      @content_entry._permalink.should == '5k'
    end

  end

  describe '#visibility' do

    before(:each) do
      @content_entry = build_content_entry
    end

    it 'is not visible by default' do
      @content_entry.send(:set_visibility)
      @content_entry.visible?.should be_false
    end

    it 'can be visible even if it is nil' do
      @content_entry.visible = nil
      @content_entry.send(:set_visibility)
      @content_entry.visible?.should be_true
    end

    it 'can not be visible' do
      @content_entry.visible = false
      @content_entry.send(:set_visibility)
      @content_entry.visible?.should be_false
    end

  end

  describe '#label' do

    it 'has a label based on the value of the first field' do
      build_content_entry._label.should == 'Locomotive'
    end

    it 'uses the to_label method if the value of the label field defined it' do
      entry = build_content_entry(:_label_field_name => 'with_to_label')
      entry.stubs(:with_to_label).returns(mock('with_to_label', :to_label => 'acme'))
      entry._label.should == 'acme'
    end

    it 'uses the to_s method at last if the label field did not define the to_label method' do
      entry = build_content_entry(:_label_field_name => 'not_a_string')
      entry.stubs(:not_a_string).returns(mock('not_a_string', :to_s => 'not_a_string'))
      entry._label.should == 'not_a_string'
    end

  end

  describe '#public_submission' do

    before(:each) do
      @account_1 = FactoryGirl.build('admin user', :id => fake_bson_id('1'))
      @account_2 = FactoryGirl.build('frenchy user', :id => fake_bson_id('2'))

      @content_type.public_submission_enabled = true
      @content_type.public_submission_accounts = ['', @account_1._id, @account_2._id.to_s]

      site = FactoryGirl.build(:site)
      site.stubs(:accounts).returns([@account_1, @account_2])

      @content_entry = build_content_entry(:site => site)
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
      Locomotive::Notifications.expects(:new_content_entry).with(@account_1, @content_entry).returns(mock('mailer', :deliver => true))
      Locomotive::Notifications.expects(:new_content_entry).with(@account_2, @content_entry).returns(mock('mailer', :deliver => true))
      @content_entry.save
    end

  end

  describe '#site' do

    it 'assigns a site when saving the content entry' do
      content_entry = build_content_entry
      content_entry.save
      content_entry.site.should_not be_nil
    end

  end

  def localize_content_type(content_type)
    content_type.entries_custom_fields.first.localized = true
    content_type.save
  end

  def build_content_entry(options = {})
    @content_type.entries.build({ :title => 'Locomotive', :description => 'Lorem ipsum....', :_label_field_name => 'title' }.merge(options))
  end

  def fake_bson_id(id)
    BSON::ObjectId(id.to_s.rjust(24, '0'))
  end
end
