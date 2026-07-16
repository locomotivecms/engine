module Locomotive
  class AccountPolicy < ApplicationPolicy

    def index?
      super_admin?
    end

    def show?
      super_admin? || owner?
    end

    def create?
      # everybody can create an account
      true
    end

    def update?
      (super_admin? || owner?) && !@resource.visitor?
    end

    def destroy?
      # can not delete himself/herself
      super_admin? && !owner?
    end

    def permitted_attributes
      attributes = [:name, :email, :locale, :password, :password_confirmation]
      attributes += [:api_key, :super_admin] if super_admin?
      attributes
    end

    private

    def owner?
      @resource._id == membership.account_id
    end

  end
end
