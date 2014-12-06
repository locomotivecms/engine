module Locomotive
  class ApplicationPolicy

    delegate :site, :account, to: :membership

    attr_reader :membership

    def initialize(membership, resource)
      @membership = membership
      @resource   = resource

      raise Pundit::NotAuthorizedError, 'must be logged in' unless account
      raise Pundit::NotAuthorizedError, 'should have a site' unless site
      raise Pundit::NotAuthorizedError, 'should have a resource' unless resource
    end

  end
end

# module Locomotive

#   module AccountMembershipWrapper
#     def membership
#       @membership ||= begin
#         begin
#           membership = current_membership
#           membership = Membership.new(account: self.user, role: 'admin') if self.user.admin?
#           membership
#         rescue
#           Membership.new(account: self.user, role: 'guest')
#         end
#       end
#     end

#     private

#     def current_membership
#       self.site.memberships.where(account_id: self.user.id).first
#     end

#   end

#   class ApplicationPolicy
#     include AccountMembershipWrapper

#     class Scope < Struct.new(:user, :site, :resource)
#       include AccountMembershipWrapper

#       def resolve
#         return [] unless user
#         Wallet.scope(user, site, resource, membership)
#       end
#     end

#     attr_reader :user, :site, :resource

#     READ_ACTIONS  = [:index, :show]
#     WRITE_ACTIONS = [:create, :new, :update, :edit, :destroy]
#     MANAGE_ACTIONS = READ_ACTIONS + WRITE_ACTIONS

#     def initialize(user, site, resource)
#       raise Pundit::NotAuthorizedError, 'must be logged in' unless user
#       raise Pundit::NotAuthorizedError, 'should have a site' unless site
#       raise Pundit::NotAuthorizedError, 'should have a resource' unless resource

#       @user   = user
#       @site   = site
#       @resource = resource
#     end

#     def create?
#       not_restricted_user? or Wallet.authorized?(user, :create, resource, membership)
#     end
#     alias_method :new?,    :create?
#     alias_method :destroy?, :create?

#     def touch?
#       puts "membership = #{membership.inspect}"
#       not_restricted_user? or Wallet.authorized?(user, :touch, resource, membership)
#     end
#     alias_method :show?,   :touch?
#     alias_method :edit?,   :touch?
#     alias_method :update?, :touch?
#     alias_method :index?,  :touch?

#     # For any actions without setting return false as fallback
#     def method_missing(method, *args, &block)
#       if self.class.method_defined? method
#         self.public_send method, *args, &block
#       elsif method.to_s =~ /\?$/
#         false # fallback as unauthorized
#       else
#         super
#       end
#     end

#     protected

#     def not_restricted_user?
#       user and user.is_admin?
#     end
#   end
# end
