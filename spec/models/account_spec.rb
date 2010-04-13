require 'spec_helper'
 
describe Account do
  
  it 'should have a valid factory' do
    Factory.build(:account).should be_valid
  end
  
  ## Validations ##
  
  %w{name email password}.each do |attr|
    it "should validate presence of #{attr}" do
      account = Factory.build(:account, attr.to_sym => nil)
      account.should_not be_valid
      account.errors[attr.to_sym].should include("can't be blank")
    end
  end
  
  it "should have a default locale" do
    account = Factory.build(:account, :locale => nil)
    account.should be_valid
    account.locale.should == 'en'
  end
  
  it "should validate uniqueness of email" do
    Factory(:account)
    (account = Factory.build(:account)).should_not be_valid
    account.errors[:email].should == ["is already taken"]
  end
  
  ## Associations ##
  
  it 'should own many sites' do
    account = Factory(:account)
    site_1 = Factory(:site, :accounts => account)
    site_2 = Factory(:site, :subdomain => 'foo', :accounts => account)
    account.sites.should == [site_1, site_2]
  end
  
end