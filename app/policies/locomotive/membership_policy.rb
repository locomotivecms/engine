module Locomotive
  class MembershipPolicy < ApplicationPolicy

    def index?
      site_admin?
    end

    def create?
      site_admin?
    end

    def update?
      site_admin?
    end

    def destroy?
      site_admin?
    end

  end
end
