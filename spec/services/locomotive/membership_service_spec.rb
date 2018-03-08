# encoding: utf-8

describe Locomotive::MembershipService do

  let(:site)                { create('test site') }
  let(:current_membership)  { site.memberships.first }
  let(:policy)              { instance_double('Policy', account: build(:account)) }
  let(:service)             { described_class.new(site, policy) }

  describe '#create' do

    let(:email) { '' }
    subject { service.create(email) }

    describe 'no account found' do

      it { expect(subject).to eq nil }

    end

    describe 'account found' do

      let(:account) { build(:account) }
      let(:email) { account.email }

      before { allow(Locomotive::Account).to receive(:find_by_email).with(account.email).and_return(account) }

      it { expect(subject).not_to eq nil }

      describe 'default role is author' do

        it { expect(subject.role).to eq 'author' }

      end

    end

  end

  describe '#change_role' do

    let(:account)     { build(:account) }
    let!(:membership) { site.memberships.build(account: account, role: 'author') }
    let(:role)        { '' }
    let(:policy)      { Locomotive::MembershipPolicy.new(current_membership, membership) }

    subject { service.change_role(membership, role) }

    describe 'invalid role' do

      it { expect(subject).to eq false }
      it { subject; expect(membership.role).to eq 'author' }

    end

    describe 'can upgrade it to an admin if we are an admin too' do

      let(:role) { 'admin' }

      it { expect(subject).to eq true }
      it { subject; expect(membership.role).to eq 'admin' }

    end

    describe 'do not have the rights to upgrade it to an admin role' do

      let(:role) { 'admin' }

      before { current_membership.role = 'designer' }

      it { expect(subject).to eq false }
      it { subject; expect(membership.errors[:role]).to eq ['is invalid'] }

    end

  end

end
