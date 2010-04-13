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
  
  it 'should validate presence of subdomain' do
    site = Factory.build(:site, :subdomain => nil)
    site.should_not be_valid
    site.errors[:subdomain].should == ["can't be blank"]
  end
    
  %w{test foo_bar test42}.each do |subdomain|
    it "should accept subdomain like '#{subdomain}'" do
      Factory.build(:site, :subdomain => subdomain).should be_valid
    end
  end
  
  ['-', '_test', 'test_', 't est', '42', '42test'].each do |subdomain|
    it "should not accept subdomain like '#{subdomain}'" do
      (site = Factory.build(:site, :subdomain => subdomain)).should_not be_valid
      site.errors[:subdomain].should == ['is invalid']
    end
  end
  
  it "should not use reserved keywords as subdomain" do
    %w{www admin email blog webmail mail support help site sites}.each do |subdomain|
      (site = Factory.build(:site, :subdomain => subdomain)).should_not be_valid
      site.errors[:subdomain].should == ['is reserved']
    end
  end
  
  it 'should validate uniqueness of subdomain' do
    Factory(:site)    
    (site = Factory.build(:site)).should_not be_valid
    site.errors[:subdomain].should == ["is already taken"]
  end
    
  it 'should validate uniqueness of domains' do
    Factory(:site, :domains => %w{www.acme.net www.acme.com})  
    (site = Factory.build(:site, :domains => %w{www.acme.com})).should_not be_valid
    site.errors[:domains].should == ["www.acme.com is already taken"]
  end
  
  it 'should validate format of domains' do
    site = Factory.build(:site, :domains => ['barformat.superlongextension', '-foo.net'])
    site.should_not be_valid
    site.errors[:domains].should == ['barformat.superlongextension is invalid', '-foo.net is invalid']
  end
  
  ## Named scopes ##
  
  it 'should retrieve sites by domain' do
    site_1 = Factory(:site, :domains => %w{www.acme.net})
    site_2 = Factory(:site, :subdomain => 'test', :domains => %w{www.example.com})
    
    sites = Site.match_domain('www.acme.net')
    sites.size.should == 1
    sites.first.should == site_1
    
    sites = Site.match_domain('www.example.com')
    sites.size.should == 1
    sites.first.should == site_2
    
    sites = Site.match_domain('test.example.com')
    sites.size.should == 1
    sites.first.should == site_2
    
    sites = Site.match_domain('www.unknown.com')
    sites.should be_empty
  end  
  
  ## Associations ##
  
  it 'should have many accounts' do
    account_1 = Factory(:account)
    account_2 = Factory(:account, :name => 'homer', :email => 'homer@simpson.net')
    site = Factory(:site, :accounts => [account_1, account_2, account_1])
    site.account_ids.should == [account_1.id, account_2.id]
    site.accounts.should == [account_1, account_2]
  end
  
  ## Methods ##
  
  it 'should return domains without subdomain' do
    site = Factory(:site, :domains => %w{www.acme.net www.acme.com})
    site.domains.should == %w{www.acme.net www.acme.com acme.example.com}
    site.domains_without_subdomain.should == %w{www.acme.net www.acme.com}
  end
  
end