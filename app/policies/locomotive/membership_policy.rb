module Locomotive
  class MembershipPolicy < ApplicationPolicy

    def index?
      site_admin?
    end

    def create?
      site_admin_or_designer?
    end

    def update?
      site_admin_or_designer? && change_role?
    end

    def destroy?
      site_admin? && change_role?
    end

    def change_role?
      site_admin?
    end

    def permitted_attributes
      if site_admin?
        [:email, :role_id]
      else
        []
      end
    end

  end
end
