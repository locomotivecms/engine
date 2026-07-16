# encoding: utf-8

describe Locomotive::SitePolicy do

  let(:site)   { build(:site) }
  let(:policy) { described_class.new(membership, site) }

  describe '#show?' do

    subject { policy.show? }

    context 'a member of the site' do
      let(:membership) { build(:membership, site: site) }
      it { is_expected.to eq true }
    end

    context 'a super admin without a membership to the site' do
      let(:membership) { Locomotive::Membership.new(account: build(:account, super_admin: true)) }
      it { is_expected.to eq true }
    end

    context 'an account with no membership to the site' do
      let(:membership) { Locomotive::Membership.new(account: build(:account)) }
      it { is_expected.to eq false }
    end

  end

end
