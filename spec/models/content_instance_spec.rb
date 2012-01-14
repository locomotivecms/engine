# encoding: utf-8

require 'spec_helper'

describe ContentInstance do

  before(:each) do
    Site.any_instance.stubs(:create_default_pages!).returns(true)
    @content_type = FactoryGirl.build(:content_type)
    @content_type.content_custom_fields.build :label => 'Title', :kind => 'String'
    @content_type.content_custom_fields.build :label => 'Description', :kind => 'Text'
    @content_type.content_custom_fields.build :label => 'Visible ?', :kind => 'Text', :_alias => 'visible'
    @content_type.highlighted_field_name = 'custom_field_1'
  end

  describe '#validation' do
    it 'is valid' do
      build_content.should be_valid
    end

    ## Validations ##

    it 'requires the presence of title' do
      content = build_content :title => nil
      content.should_not be_valid
      content.errors[:title].should == ["can't be blank"]
    end

    it 'requires the presence of the permalink (_slug)' do
      content = build_content :title => nil
      content.should_not be_valid
      content.errors[:_slug].should == ["can't be blank"]
    end
  end

  context 'setting the slug' do
    before :each do
      build_content(:_slug => 'dogs').tap(&:save!)._slug.should == 'dogs'
    end

    it 'uses the given slug if it is unique' do
      build_content(:_slug => 'monkeys').tap(&:save!)._slug.should == 'monkeys'
      build_content(:_slug => 'cats-2').tap(&:save!)._slug.should == 'cats-2'
    end

    it 'appends a number to the end of the slug if it is not unique' do
      build_content(:_slug => 'dogs').tap(&:save!)._slug.should == 'dogs-1'
      build_content(:_slug => 'dogs').tap(&:save!)._slug.should == 'dogs-2'
      build_content(:_slug => 'dogs-2').tap(&:save!)._slug.should == 'dogs-3'
      build_content(:_slug => 'dogs-2').tap(&:save!)._slug.should == 'dogs-4'
    end

    it 'ignores the case of a slug' do
      build_content(:_slug => 'dogs').tap(&:save!)._slug.should == 'dogs-1'
      build_content(:_slug => 'DOGS').tap(&:save!)._slug.should == 'dogs-2'
    end

    it 'correctly handles slugs with multiple numbers' do
      build_content(:_slug => 'fish-1-2').tap(&:save!)._slug.should == 'fish-1-2'
      build_content(:_slug => 'fish-1-2').tap(&:save!)._slug.should == 'fish-1-3'

      build_content(:_slug => 'fish-1-hi').tap(&:save!)._slug.should == 'fish-1-hi'
      build_content(:_slug => 'fish-1-hi').tap(&:save!)._slug.should == 'fish-1-hi-1'
    end
  end

  describe "#navigation" do
    before(:each) do
      %w(first second third).each_with_index do |item,index|
        content = build_content({:title => item.to_s})
        content._position_in_list = index
        instance_variable_set "@#{item}", content
      end
    end

    it 'should find previous item when available' do
      @second.previous.custom_field_1.should == "first"
      @second.previous._position_in_list.should == 0
    end

    it 'should find next item when available' do
      @second.next.custom_field_1.should == "third"
      @second.next._position_in_list.should == 2
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
      @content = build_content
    end

    it 'has a default value based on the highlighted field' do
      @content.send(:set_slug)
      @content._permalink.should == 'locomotive'
    end

    it 'is empty if no value for the highlighted field is provided' do
      @content.title = nil; @content.send(:set_slug)
      @content._permalink.should be_nil
    end

    it 'includes dashes instead of white spaces' do
      @content.title = 'my content instance'; @content.send(:set_slug)
      @content._permalink.should == 'my-content-instance'
    end

    it 'removes accentued characters' do
      @content.title = "une chèvre dans le pré"; @content.send(:set_slug)
      @content._permalink.should == 'une-chevre-dans-le-pre'
    end

    it 'removes dots' do
      @content.title = "my.test"; @content.send(:set_slug)
      @content._permalink.should == 'my-test'
    end

  end

  describe '#visibility' do

    before(:each) do
      @content = build_content
    end

    it 'is visible by default' do
      @content._visible?.should be_true
      @content.visible?.should be_true
    end

    it 'can be visible even if it is nil' do
      @content.visible = nil
      @content.send(:set_visibility).should be_true
      @content.visible?.should be_true
    end

    it 'can not be visible' do
      @content.visible = false
      @content.send(:set_visibility).should be_true
      @content.visible?.should be_false
    end

  end

  describe '#requirements' do

    it 'has public access to the highlighted field value' do
      build_content.highlighted_field_value.should == 'Locomotive'
    end

  end

  describe '#api' do

    before(:each) do
      @account_1 = FactoryGirl.build('admin user', :id => fake_bson_id('1'))
      @account_2 = FactoryGirl.build('frenchy user', :id => fake_bson_id('2'))

      @content_type.api_enabled = true
      @content_type.api_accounts = ['', @account_1.id, @account_2.id]

      Site.any_instance.stubs(:accounts).returns([@account_1, @account_2])

      @content = build_content
    end

    it 'does not send email notifications if the api is disabled' do
      @content_type.api_enabled = false
      Admin::Notifications.expects(:new_content_instance).never
      @content.save
    end

    it 'does not send email notifications if no api accounts' do
      @content_type.api_accounts = nil
      Admin::Notifications.expects(:new_content_instance).never
      @content.save
    end

    it 'sends email notifications when a new instance is created' do
      Admin::Notifications.expects(:new_content_instance).with(@account_1, @content).returns(mock('mailer', :deliver => true))
      Admin::Notifications.expects(:new_content_instance).with(@account_2, @content).returns(mock('mailer', :deliver => true))
      @content.save
    end

  end

  describe '#site' do
    it 'delegates to the content type' do
      @content_type.expects(:site)
      build_content.site
    end
  end

  after(:all) do
    ENV['APP_TLD'] = nil
    Locomotive.configure_for_test(true)
  end

  def build_content(options = {})
    @content_type.contents.build({ :title => 'Locomotive', :description => 'Lorem ipsum....' }.merge(options))
  end

  def fake_bson_id(id)
    BSON::ObjectId(id.to_s.rjust(24, '0'))
  end
end
