module Locomotive
  class ContentTypePolicy < ApplicationPolicy

    def index?
      true
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
