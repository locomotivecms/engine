require 'spec_helper'

describe Locomotive::Membership do

  it 'should have a valid factory' do
    FactoryGirl.build(:membership, account: FactoryGirl.build(:account)).should be_valid
  end

  it 'should validate presence of account' do
    membership = FactoryGirl.build(:membership, account: nil)
    membership.should_not be_valid
    membership.errors[:account].should == ["can't be blank"]
  end

  it 'should assign account from email' do
    Locomotive::Account.stubs(:where).returns([FactoryGirl.build(:account)])
    Locomotive::Account.stubs(:find).returns(FactoryGirl.build(:account))
    membership = FactoryGirl.build(:membership, account: nil)
    membership.email = 'bart@simpson.net'
    membership.account.should_not be_nil
    membership.account.name.should == 'Bart Simpson'
  end

  describe 'next action to take' do

    before(:each) do
      @membership = FactoryGirl.build(:membership, site: FactoryGirl.build(:site))
      @account = FactoryGirl.build(:account)
      @account.stubs(:save).returns(true)
      Locomotive::Account.stubs(:where).returns([@account])
      Locomotive::Account.stubs(:find).returns(@account)
    end

    it 'should tell error' do
      @membership.process!.should == :error
    end

    it 'should tell we need to create a new account' do
      Locomotive::Account.stubs(:where).returns([])
      @membership.email = 'homer@simpson'
      @membership.process!.should == :create_account
    end

    it 'should tell nothing to do' do
      @membership.email = 'bart@simpson.net'
      @membership.site.stubs(:memberships).returns([self.build_membership(@account), self.build_membership])
      @membership.process!.should == :already_created
    end

    it 'should tell membership has to be saved' do
      @membership.email = 'bart@simpson.net'
      @membership.process!.should == :save_it
    end

    def build_membership(account = nil)
      FactoryGirl.build(:membership, site: FactoryGirl.build(:site), account: account || FactoryGirl.build(:account))
    end

  end

end
