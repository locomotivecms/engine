require 'spec_helper'
 
describe ContentType do
  
  before(:each) do
    Site.any_instance.stubs(:create_default_pages!).returns(true)
  end
  
  context 'when validating' do
    
    it 'should have a valid factory' do
      content_type = Factory.build(:content_type)
      content_type.content_custom_fields.build :label => 'anything', :kind => 'String'
      content_type.should be_valid
    end
  
    # Validations ##
  
    %w{site name}.each do |field|
      it "should validate presence of #{field}" do
        content_type = Factory.build(:content_type, field.to_sym => nil)
        content_type.should_not be_valid
        content_type.errors[field.to_sym].should == ["can't be blank"]
      end
    end
  
    it 'should validate presence of slug' do
      content_type = Factory.build(:content_type, :name => nil, :slug => nil)
      content_type.should_not be_valid
      content_type.errors[:slug].should == ["can't be blank"]
    end
  
    it 'should validate uniqueness of slug' do
      content_type = Factory.build(:content_type)
      content_type.content_custom_fields.build :label => 'anything', :kind => 'String'
      content_type.save
      (content_type = Factory.build(:content_type, :site => content_type.site)).should_not be_valid
      content_type.errors[:slug].should == ["is already taken"]
    end
    
    it 'should validate size of content custom fields' do
      content_type = Factory.build(:content_type)
      content_type.should_not be_valid
      content_type.errors[:content_custom_fields].should == ["is too small (minimum element number is 1)"]
    end
    
  end
  
end