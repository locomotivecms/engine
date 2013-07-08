require 'spec_helper'

describe Locomotive::CustomFieldsHelper do

  before(:each) do
    Locomotive::Site.any_instance.stubs(:create_default_pages!).returns(true)
    @content_type = FactoryGirl.build(:content_type)
    @content_type.entries_custom_fields.build label: 'Title', type: 'string'
    @content_type.entries_custom_fields.build label: 'Description', type: 'text'
    @content_type.entries_custom_fields.build label: 'Visible ?', type: 'boolean', name: 'visible'
    @content_type.entries_custom_fields.build label: 'File', type: 'file'
    @content_type.valid?
    @content_type.send(:set_label_field)
  end

  describe 'translatable_status' do

    it "should declare a localized field as translatable" do
      localize_content_type @content_type
      @content_type.entries_custom_fields.map do |field|
        translatable_status(field).should == :translatable
      end
    end

    it "should declare a non-localized field as untranslatable" do
      localize_content_type @content_type, false
      @content_type.entries_custom_fields.map do |field|
        translatable_status(field).should == :untranslatable
      end
    end

  end

  describe 'custom_field_label' do

    it "should return the label with the translatable status for localized fields" do
      localize_content_type @content_type
      @content_type.entries_custom_fields.map do |field|
        custom_field_label(field).should == "#{field.label} <span class=\"translatable\">Translatable</span>"
      end
    end

    it "should return the label with the translatable status for non-localized fields" do
      localize_content_type @content_type, false
      @content_type.entries_custom_fields.map do |field|
        custom_field_label(field).should == "#{field.label} <span class=\"untranslatable\">Untranslatable</span>"
      end
    end

  end

  def localize_content_type(content_type, status = true)
    content_type.entries_custom_fields.map do |field|
      field.localized = status
    end
    content_type.save
  end

end
