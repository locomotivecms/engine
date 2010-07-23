require 'spec_helper'

describe Membership do

  it 'should have a valid factory' do
    Factory.build(:membership, :account => Factory.build(:account)).should be_valid
  end

  it 'should validate presence of account' do
    membership = Factory.build(:membership, :account => nil)
    membership.should_not be_valid
    membership.errors[:account].should == ["can't be blank"]
  end

  it 'should assign account from email' do
    Account.stubs(:where).returns([Factory.build(:account)])
    Account.stubs(:find).returns(Factory.build(:account))
    membership = Factory.build(:membership, :account => nil)
    membership.email = 'bart@simpson.net'
    membership.account.should_not be_nil
    membership.account.name.should == 'Bart Simpson'
  end

  describe 'next action to take' do

    before(:each) do
      @membership = Factory.build(:membership, :site => Factory.build(:site))
      @account = Factory.build(:account)
      @account.stubs(:save).returns(true)
      Account.stubs(:where).returns([@account])
      Account.stubs(:find).returns(@account)
    end

    it 'should tell error' do
      @membership.process!.should == :error
    end

    it 'should tell we need to create a new account' do
      Account.stubs(:where).returns([])
      @membership.email = 'homer@simpson'
      @membership.process!.should == :create_account
    end

    it 'should tell nothing to do' do
      @membership.email = 'bart@simpson.net'
      @membership.site.stubs(:memberships).returns([@membership, @membership])
      @membership.process!.should == :nothing
    end

    it 'should tell membership has to be saved' do
      @membership.email = 'bart@simpson.net'
      @membership.process!.should == :save_it
    end
  end

end
