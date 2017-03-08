require 'spec_helper'

describe Locomotive::Shared::AccountsHelper do

  describe 'account_avatar_url' do

    let(:account) { create(:account, avatar: FixturedAsset.open('5k.png')).reload }

    subject { account_avatar_url(account) }

    it { expect(subject).to match(/^\/images\/dynamic\/[^\/]+\/5k.png\?sha=.*$/) }

  end

end


