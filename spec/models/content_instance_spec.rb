require 'spec_helper'
 
describe ContentInstance do
  
  before(:each) do
    Site.any_instance.stubs(:create_default_pages!).returns(true)
    @content_type = Factory.build(:content_type)
    @content_type.content_custom_fields.build :label => 'Title', :kind => 'String'
    @content_type.content_custom_fields.build :label => 'Description', :kind => 'Text'
    @content_type.highlighted_field_name = 'custom_field_1'
  end

  context 'when validating' do
  
    it 'should be valid' do
      build_content.should be_valid
    end
  
    # Validations ##
    
    it 'should validate presence of title' do
      content = build_content :title => nil
      content.should_not be_valid
      content.errors[:title].should == ["can't be blank"]
    end
    
  end
  
  def build_content(options = {})
    @content_type.contents.build({ :title => 'Locomotive', :description => 'Lorem ipsum....' }.merge(options))
  end
  
end