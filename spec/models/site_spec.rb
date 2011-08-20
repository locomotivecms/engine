require 'spec_helper'

describe Site do

  it 'should have a valid factory' do
    FactoryGirl.build(:site).should be_valid
  end

  ## Validations ##

  it 'should validate presence of name' do
    site = FactoryGirl.build(:site, :name => nil)
    site.should_not be_valid
    site.errors[:name].should == ["can't be blank"]
  end

  it 'should validate presence of subdomain' do
    site = FactoryGirl.build(:site, :subdomain => nil)
    site.should_not be_valid
    site.errors[:subdomain].should == ["can't be blank"]
  end

  %w{test test42 foo_bar}.each do |subdomain|
    it "should accept subdomain like '#{subdomain}'" do
      FactoryGirl.build(:site, :subdomain => subdomain).should be_valid
    end
  end

  ['-', '_test', 'test_', 't est', '42', '42test'].each do |subdomain|
    it "should not accept subdomain like '#{subdomain}'" do
      (site = FactoryGirl.build(:site, :subdomain => subdomain)).should_not be_valid
      site.errors[:subdomain].should == ['is invalid']
    end
  end

  it "should not use reserved keywords as subdomain" do
    %w{www admin email blog webmail mail support help site sites}.each do |subdomain|
      (site = FactoryGirl.build(:site, :subdomain => subdomain)).should_not be_valid
      site.errors[:subdomain].should == ['is reserved']
    end
  end

  it 'should validate uniqueness of subdomain' do
    FactoryGirl.create(:site)
    (site = FactoryGirl.build(:site)).should_not be_valid
    site.errors[:subdomain].should == ["is already taken"]
  end

  it 'should validate uniqueness of domains' do
    FactoryGirl.create(:site, :domains => %w{www.acme.net www.acme.com})

    (site = FactoryGirl.build(:site, :domains => %w{www.acme.com})).should_not be_valid
    site.errors[:domains].should == ["www.acme.com is already taken"]

    (site = FactoryGirl.build(:site, :subdomain => 'foo', :domains => %w{acme.example.com})).should_not be_valid
    site.errors[:domains].should == ["acme.example.com is already taken"]
  end

  it 'should validate format of domains' do
    site = FactoryGirl.build(:site, :domains => ['barformat.superlongextension', '-foo.net'])
    site.should_not be_valid
    site.errors[:domains].should == ['barformat.superlongextension is invalid', '-foo.net is invalid']
  end

  ## Named scopes ##

  it 'should retrieve sites by domain' do
    site_1 = FactoryGirl.create(:site, :domains => %w{www.acme.net})
    site_2 = FactoryGirl.create(:site, :subdomain => 'test', :domains => %w{www.example.com})

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
    site = FactoryGirl.build(:site)
    account_1, account_2 = FactoryGirl.create(:account), FactoryGirl.create(:account, :name => 'homer', :email => 'homer@simpson.net')
    site.memberships.build(:account => account_1, :admin => true)
    site.memberships.build(:account => account_2)
    site.memberships.size.should == 2
    site.accounts.should == [account_1, account_2]
  end

  ## Methods ##

  it 'should return domains without subdomain' do
    site = FactoryGirl.create(:site, :domains => %w{www.acme.net www.acme.com})
    site.domains.should == %w{www.acme.net www.acme.com acme.example.com}
    site.domains_without_subdomain.should == %w{www.acme.net www.acme.com}
  end

  describe 'once created' do

    before(:each) do
      @site = FactoryGirl.create(:site)
    end

    it 'should create index and 404 pages' do
      @site.pages.size.should == 2
      @site.pages.map(&:fullpath).sort.should == %w{404 index}
    end

  end

  describe 'deleting in cascade' do

    before(:each) do
      @site = FactoryGirl.create(:site)
    end

    it 'should also destroy pages' do
      lambda {
        @site.destroy
      }.should change(Page, :count).by(-2)
    end

  end

end
