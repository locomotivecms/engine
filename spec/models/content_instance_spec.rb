require 'spec_helper'
 
describe ContentInstance do
  
  before(:each) do
    Site.any_instance.stubs(:create_default_pages!).returns(true)
    @content_type = Factory.build(:content_type)
    @content_type.content_custom_fields.build :label => 'Title', :kind => 'String'
    @content_type.content_custom_fields.build :label => 'Description', :kind => 'Text'
    @content_type.content_custom_fields.build :label => 'Visible ?', :kind => 'Text', :_alias => 'visible'
    @content_type.highlighted_field_name = 'custom_field_1'
  end

  describe '#validation' do
  
    it 'is valid' do
      build_content.should be_valid
    end
  
    # Validations ##
    
    it 'requires presence of title' do
      content = build_content :title => nil
      content.should_not be_valid
      content.errors[:title].should == ["can't be blank"]
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
      @content.send(:set_visibility)
      @content.visible?.should be_true
    end
    
    it 'can not be visible' do
      @content.visible = false
      @content.send(:set_visibility)
      @content.visible?.should be_false
    end
  
  end
  
  def build_content(options = {})
    @content_type.contents.build({ :title => 'Locomotive', :description => 'Lorem ipsum....' }.merge(options))
  end
  
end