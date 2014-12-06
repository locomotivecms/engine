module Locomotive
  class AccountPolicy < ApplicationPolicy

    def create?
      membership.admin?
    end

    def edit?
      membership.admin?
    end

    def update?
      membership.admin? || membership.account_id == resource._id
    end

    def destroy?
      membership.admin?
    end

  end
end
