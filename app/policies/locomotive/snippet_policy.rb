module Locomotive
  class SnippetPolicy < ApplicationPolicy

    class Scope < Struct.new(:user)

      def resolve
        self.user.to_scope(:site).resolve
      end
    end

    def membership
      @membership ||= begin
        _membership = if self.record
          self.record.memberships.where(account_id: self.user.id).first
        elsif self.user.admin?
          Membership.new(account: self.user, role: 'admin')
        end
        unless _membership
          _membership = Membership.new(account: self.user, role: 'guest')
        end
        _membership
      end
    end

    def create?
      super or self.membership.to_policy(:site, user, record, membership).create?
    end
    alias_method :new?,    :create?
    alias_method :destroy, :create?

    def touch?
      not_restricted_user? or self.membership.to_policy(:site, user, record, membership).touch?
    end
    alias_method :show?,   :touch?
    alias_method :edit?,   :touch?
    alias_method :update?, :touch?
    alias_method :index?,  :touch?

  end
end
