module Locomotive
  class SitePolicy < ApplicationPolicy

    class Scope < Scope

      def resolve
        if membership.account.super_admin?
          scope.all
        else
          membership.account.sites
        end
      end

    end

    def index?
      true
    end

    def show?
      true
    end

    def create?
      true
    end

    def update?
      true
    end

    def destroy?
      super_admin? || site_admin?
    end

  end
end
