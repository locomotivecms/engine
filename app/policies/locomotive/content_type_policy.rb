module Locomotive
  class ContentTypePolicy < ApplicationPolicy

    def index?
      site_staff?
    end

    def create?
      site_admin_or_designer?
    end

    def update?
      site_admin_or_designer?
    end

    def destroy?
      site_admin_or_designer?
    end

    def destroy_all?
      site_admin_or_designer?
    end

    def show?
      site_admin_or_designer? || !@resource.hidden?
    end

  end
end
