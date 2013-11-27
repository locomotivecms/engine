require 'spec_helper'

describe Locomotive::ContentEntriesHelper do

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
  describe 'label_for_custom_field' do

    it "should return the label with the translatable icon for localized fields" do
      localize_content_type @content_type
      @content_type.entries_custom_fields.map do |field|
        label_for_custom_field(field).should == %(<span class="localized-icon"><i class="icon-flag"></i></span>#{field.label})
      end
    end

    it "should return the label with the translatable icon for non-localized fields" do
      localize_content_type @content_type, false
      @content_type.entries_custom_fields.map do |field|
        label_for_custom_field(field).should == field.label
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
