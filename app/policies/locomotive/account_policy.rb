module Locomotive
  class AccountPolicy < ApplicationPolicy

    class Scope < Struct.new(:user)

      def resolve
        return [] unless user

        # self.user.to_scope(:site).resolve
        if user.is_admin?
          Locomotive::Account
        else
          []
        end
      end

      def find id
        # return nil unless user

        if user.is_admin?
          Locomotive::Account.find id
        else
          user
        end
      end
    end

    def update?
      super or Wallet.authorized?(user, record, :touch)
      # super or self.membership.to_policy(:account, user, record, membership).touch?
    end
    alias_method :destroy?, :update?

  end
end
