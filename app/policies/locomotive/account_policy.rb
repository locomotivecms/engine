module Locomotive
  class AccountPolicy < ApplicationPolicy

    def index?
      super_admin?
    end

    def show?
      super_admin? || @resource._id == membership.account_id
    end

    def create?
      # everybody can create an account
      true
    end

    def update?
      super_admin? || @resource._id == membership.account_id
    end

    def destroy?
      # can not delete himself/herself
      super_admin? && @resource._id != membership.account_id
    end

  end
end
