module Locomotive
  class ThemeAssetPolicy < ApplicationPolicy

    def index?
      site_admin_or_designer?
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

  end
end
