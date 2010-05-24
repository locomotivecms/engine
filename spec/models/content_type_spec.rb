require 'spec_helper'
 
describe ContentType do
  
  before(:each) do
    Site.any_instance.stubs(:create_default_pages!).returns(true)
  end
  
  it 'should have a valid factory' do
    Factory.build(:content_type).should be_valid
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
    content_type = Factory(:content_type)
    (content_type = Factory.build(:content_type, :site => content_type.site)).should_not be_valid
    content_type.errors[:slug].should == ["is already taken"]
  end
  
end