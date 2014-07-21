require 'spec_helper'

module Locomotive
  describe ApplicationPolicy do
    let(:record) { mock('record') }
    let(:user)   { create('admin user') }

    subject { ApplicationPolicy }

    context 'admin' do
      before do
        user.expects(:is_admin?).at_least_once.returns(true)
      end

      permissions *ApplicationPolicy::MANAGE_ACTIONS.map { |action| action.to_s + '?' } do
        it('yes') { expect(subject).to permit(user, record) }
      end
    end

    context 'anybody else' do
      let(:user) { create(:account) }

      permissions *ApplicationPolicy::MANAGE_ACTIONS.map { |action| action.to_s + '?' } do
        it('no') { expect(subject).to_not permit(user, record) }
      end
    end
  end
end
