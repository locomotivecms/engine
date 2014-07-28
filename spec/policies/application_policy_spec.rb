require 'spec_helper'

module Locomotive

  describe ApplicationPolicy do
    let(:resource) { :site}
    let(:user)   { create('admin user') }
    let(:site) { create :site }

    subject { ApplicationPolicy }

    context 'admin' do

      module AccountMembershipWrapper
        def membership()
          Membership.new(account: self.user, role: 'admin')
        end
      end

      before do
        user.expects(:is_admin?).at_least_once.returns(true)
      end

      permissions *ApplicationPolicy::MANAGE_ACTIONS.map { |action| action.to_s + '?' } do
        it('yes') { expect(subject).to permit(user, site, resource) }
      end
    end

    context 'anybody else' do

      module AccountMembershipWrapper
        def membership()
          Membership.new(account: self.user, role: 'guest')
        end
      end

      permissions *ApplicationPolicy::MANAGE_ACTIONS.map { |action| action.to_s + '?' } do
        it('no') { expect(subject).to_not permit(user, site, resource) }
      end
    end
  end
end
