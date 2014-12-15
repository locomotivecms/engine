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

    # The role cannot be set higher than the current one (we use the index in
    # the roles array to check role presidence)
    def change_role?
      roles = Locomotive::Membership::ROLES
      roles.index(resource.role.to_s) <= roles.index(membership.role.to_s)
    end

    def permitted_attributes
      if site_admin?
        [:email, :role]
      else
        []
      end
    end

  end
end
