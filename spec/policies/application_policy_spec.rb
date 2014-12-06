# FIXME (Did): DEPRECATED

# require 'spec_helper'

# module Locomotive

#   describe ApplicationPolicy do
#     let(:resource)  { :site }
#     let(:user)      { create('admin user').tap { |a| puts a._id.inspect } }
#     let(:site)      { create :site }

#     subject { ApplicationPolicy }

#     context 'admin' do

#       before do
#         ApplicationPolicy.any_instance.stubs(:membership).returns(Membership.new(account: self.user, role: 'guest'))
#       end

#       before do
#         user.expects(:is_admin?).at_least_once.returns(true)
#       end

#       permissions *ApplicationPolicy::MANAGE_ACTIONS.map { |action| action.to_s + '?' } do
#         it('yes') { expect(subject).to permit(user, site, resource) }
#       end
#     end

#     # context 'anybody else' do

#     #   before do
#     #     ApplicationPolicy.any_instance.stubs(:membership).returns(Membership.new(account: self.user, role: 'guest'))
#     #   end

#     #   permissions *ApplicationPolicy::MANAGE_ACTIONS.map { |action| action.to_s + '?' } do
#     #     it('no') { expect(subject).to_not permit(user, site, resource) }
#     #   end
#     # end
#   end
# end
