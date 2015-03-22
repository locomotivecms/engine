require 'spec_helper'

module Locomotive
  describe MembershipEntity do
    subject { MembershipEntity }

    it { is_expected.to represent(:role) }
    it { is_expected.to represent(:account_id) }

    context 'overrides' do
      let!(:account) { create(:account) }
      let!(:membership) { create(:membership, account: account) }
      subject { Locomotive::MembershipEntity.new(membership) }
      let(:exposure) { subject.serializable_hash }


      describe 'name' do
        it 'returns the name from the account' do
          expect(exposure[:name]).to eq account.name
        end
      end

      context 'with policies' do
        subject { Locomotive::MembershipEntity.new(membership, policy: policy) }
        context 'admin' do
          let(:policy) { Locomotive::MembershipPolicy.new(create(:admin), membership) }
          describe '#can_update' do
            it 'is true' do
              expect(exposure[:can_update]).to be_truthy
            end
          end

          describe '#grant_admin' do
            it 'is true' do
              expect(exposure[:grant_admin]).to be_truthy
            end
          end
        end

        context 'editor' do
          let(:policy) { Locomotive::MembershipPolicy.new(create(:author), membership) }
          describe '#can_update' do
            it 'is false' do
              expect(exposure[:can_update]).to be_falsy
            end
          end

          describe '#grant_admin' do
            it 'is false' do
              expect(exposure[:grant_admin]).to be_falsy
            end
          end
        end
      end

    end

  end
end
