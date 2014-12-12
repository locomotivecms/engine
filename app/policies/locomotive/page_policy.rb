module Locomotive
  class PagePolicy < ApplicationPolicy

    def index?
      true
    end

    def create?
      true
    end

    def update?
      true
    end

    def destroy?
      site_admin_or_designer?
    end

  end
end
