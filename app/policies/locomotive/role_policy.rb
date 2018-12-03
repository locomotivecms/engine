module Locomotive
  class RolePolicy < ApplicationPolicy

    def index?
      site_admin?
    end

    def new?
      site_admin?
    end

    def create?
      site_admin?
    end

    def edit?
      site_admin? and !@resource.is_admin?
    end

    def update?
      site_admin?
    end

    def destroy?
      site_admin?
    end

    def permitted_attributes
      if site_admin?
        [ :name, :role_pages_str, :superior_id, role_models: [] ]
      else
        []
      end
    end

  end
end
