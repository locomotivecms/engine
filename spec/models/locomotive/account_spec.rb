require 'spec_helper'

describe Account do

  it 'should have a valid factory' do
    FactoryGirl.build(:account).should be_valid
  end

  ## Validations ##

  %w{name email password}.each do |attr|
    it "should validate presence of #{attr}" do
      account = FactoryGirl.build(:account, attr.to_sym => nil)
      account.should_not be_valid
      account.errors[attr.to_sym].should include("can't be blank")
    end
  end

  it "should have a default locale" do
    account = Account.new
    account.locale.should == 'en'
  end

  it "should validate uniqueness of email" do
    FactoryGirl.create(:account)
    (account = FactoryGirl.build(:account)).should_not be_valid
    account.errors[:email].should == ["is already taken"]
  end

  ## Associations ##

  it 'should own many sites' do
    account = FactoryGirl.create(:account)
    site_1 = FactoryGirl.create(:site, :memberships => [Membership.new(:account => account)])
    site_2 = FactoryGirl.create(:site, :subdomain => 'foo', :memberships => [Membership.new(:account => account)])
    account.reload.sites.to_a.should == [site_1, site_2]
  end

  describe 'deleting' do

    before(:each) do
      @account = FactoryGirl.build(:account)
      @site_1 = FactoryGirl.build(:site, :subdomain => 'foo', :memberships => [FactoryGirl.build(:membership, :account => @account)])
      @site_2 = FactoryGirl.build(:site, :subdomain => 'bar', :memberships => [FactoryGirl.build(:membership, :account => @account)])
      @account.stubs(:sites).returns([@site_1, @site_2])
      Site.any_instance.stubs(:save).returns(true)
    end

    it 'should also delete memberships' do
      Site.any_instance.stubs(:admin_memberships).returns(['junk', 'dirt'])
      @site_1.memberships.first.expects(:destroy)
      @site_2.memberships.first.expects(:destroy)
      @account.destroy
    end

    it 'should raise an exception if account is the only remaining admin' do
      @site_1.memberships.first.stubs(:admin?).returns(true)
      @site_1.stubs(:admin_memberships).returns(['junk'])
      lambda {
        @account.destroy
      }.should raise_error(Exception, "One admin account is required at least")
    end

  end

  describe 'cross domain authentication' do

    before(:each) do
      @account = FactoryGirl.build(:account)
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

  after(:all) do
    ENV['APP_TLD'] = nil
    Locomotive.configure_for_test(true)
  end

end
