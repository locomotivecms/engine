require 'spec_helper'

describe Locomotive::API::Entities::MembershipEntity do

  subject { described_class }

  it { is_expected.to represent(:role) }

  context 'overrides' do
    let!(:account) { create(:account) }
    let!(:membership) { create(:membership, account: account) }
    subject { described_class.new(membership) }
    let(:exposure) { subject.serializable_hash }


    describe 'name' do
      it 'returns the name from the account' do
        expect(exposure[:name]).to eq account.name
      end
    end

    describe 'account_id' do
      it 'returns the string value of the account id' do
        expect(exposure[:account_id]).to eq(account.id.to_s)
      end
    end

  end

end
