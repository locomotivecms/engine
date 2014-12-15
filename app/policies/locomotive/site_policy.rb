module Locomotive
  class SitePolicy < ApplicationPolicy

    class Scope < Scope

      def resolve
        if membership.account.super_admin?
          scope.all
        else
          membership.account.sites
        end
      end

    end

    def index?
      true
    end

    def show?
      true
    end

    def create?
      true
    end

    def update?
      true
    end

    def destroy?
      super_admin? || site_admin?
    end

    def point?
      super_admin? || site_admin?
    end

    def update_advanced?
      super_admin? || site_admin?
    end

    def permitted_attributes
      defaults = [:name, :picture, :remove_picture, :subdomain, :domains, :seo_title, :meta_keywords, :meta_description, :locales, :timezone_name, :robots_txt]

      defaults -= [:subdomain, :domains] unless point?
      defaults -= [:locales, :timezone_name, :robots_txt] unless update_advanced?

      defaults
    end

  end
end
