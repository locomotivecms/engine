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
    account = Account.new
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
    site_1 = Factory(:site, :memberships => [Membership.new(:account => account)])
    site_2 = Factory(:site, :subdomain => 'foo', :memberships => [Membership.new(:account => account)])
    account.sites.should == [site_1, site_2]
  end

  describe 'deleting' do

    before(:each) do
      @account = Factory.build(:account)
      @site_1 = Factory.build(:site, :subdomain => 'foo', :memberships => [Factory.build(:membership, :account => @account)])
      @site_2 = Factory.build(:site, :subdomain => 'bar', :memberships => [Factory.build(:membership, :account => @account)])
      @account.stubs(:sites).returns([@site_1, @site_2])
      Site.any_instance.stubs(:save).returns(true)
    end

    it 'should also delete memberships' do
      Site.any_instance.stubs(:admin_memberships).returns(['junk'])
      @account.destroy
      @site_1.memberships.should be_empty
      @site_2.memberships.should be_empty
    end

    it 'should raise an exception if account is the only remaining admin' do
      @site_1.stubs(:admin_memberships).returns(['junk'])
      lambda {
        @account.destroy
      }.should raise_error(Exception, "One admin account is required at least")
    end

  end

  describe 'cross domain authentication' do

    before(:each) do
      @account = Factory.build(:account)
      @account.stubs(:save).returns(true)
    end

    it 'sets a token' do
      @account.reset_switch_site_token!.should be_true
      @account.switch_site_token.should_not be_empty
    end

    context 'retrieving an account' do

      it 'does not find it with an empty token' do
        Account.find_using_switch_site_token(nil).should be_nil
      end

      it 'raises an exception if not found' do
        lambda {
          Account.find_using_switch_site_token!(nil)
        }.should raise_error(Mongoid::Errors::DocumentNotFound)
      end

    end


  end

end
