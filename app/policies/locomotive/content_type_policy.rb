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

  end
end
