module Locomotive
  class PagePolicy < ApplicationPolicy

    def index?
      site_staff?
    end

    def create?
      site_staff?
    end

    def update?
      site_staff?
    end

    def destroy?
      site_admin_or_designer?
    end

  end
end
