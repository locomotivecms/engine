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
      super_admin? || site_staff?
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

    def show_developers_documentation?
      super_admin? || site_admin?
    end

    def permitted_attributes
      plain = [:name, :handle, :picture, :remove_picture, :seo_title, :meta_keywords, :meta_description, :timezone_name, :robots_txt]
      hash  = { domains: [], locales: [] }

      unless update_advanced?
        plain -= [:timezone_name, :robots_txt]
        hash.delete(:locales)
      end

      unless point?
        plain -= [:handle]
        hash.delete(:domains)
      end

      plain << hash
    end

  end
end
