module Locomotive
  class AccountPolicy < ApplicationPolicy

    def index?
      # TODO: only super admin
    end

    def create?
      membership.admin?
    end

    def update?
      membership.admin? || @resource._id == membership.account_id
    end

    def destroy?
      # TODO: only super admin
      # membership.admin?
    end

  end
end
