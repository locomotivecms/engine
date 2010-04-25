require 'spec_helper'
 
describe Page do
  
  it 'should have a valid factory' do
    Factory.build(:page).should be_valid
  end
  
  ## Validations ##
  
  %w{site title path}.each do |field|
    it "should validate presence of #{field}" do
      page = Factory.build(:page, field.to_sym => nil)
      page.should_not be_valid
      page.errors[field.to_sym].should == ["can't be blank"]
    end
  end
  
  it 'should validate uniqueness of path' do
    page = Factory(:page)
    (page = Factory.build(:page, :site => page.site)).should_not be_valid
    page.errors[:path].should == ["is already taken"]
  end
  
  ## Named scopes ##
  
  ## Associations ##
    
  ## Methods ##
  
  describe 'once created' do
  
    it 'should add the body part' do
      page = Factory(:page)
      page.parts.should_not be_empty
      page.parts.first.name.should == 'body'
    end
    
  end
  
    
end