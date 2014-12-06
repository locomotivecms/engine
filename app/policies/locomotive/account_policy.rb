module Locomotive
  class AccountPolicy < ApplicationPolicy

    def create?
      membership.admin?
    end

    def update?
      membership.admin? || @resource._id == membership.account_id
    end

    def destroy?
      membership.admin?
    end

  end
end
