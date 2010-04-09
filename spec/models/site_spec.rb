require 'spec_helper'
 
describe Site do
  
  it 'should have a valid factory' do
    Factory.build(:site).should be_valid
  end
  
  ## Validations ##
  
  it 'should validate presence of name' do
    site = Factory.build(:site, :name => nil)
    site.should_not be_valid
    site.errors[:name].should == ["can't be blank"]
  end
  
  it 'should have a domain at minimum' do
    site = Factory.build(:site, :subdomain => nil)
    site.should_not be_valid
    site.domains = %w{acme.net}
    site.should be_valid
  end
  
end