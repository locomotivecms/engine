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
      !resource.try(:persisted?) || super_admin? || site_admin?
    end

    def update_advanced?
      super_admin? || site_admin?
    end

    def show_developers_documentation?
      super_admin? || site_admin?
    end

    def permitted_attributes
      plain = [:name, :handle, :picture, :remove_picture, :seo_title, :meta_keywords, :meta_description, :timezone_name, :robots_txt, :cache_enabled, :redirect_to_first_domain, :redirect_to_https, :private_access, :password, :prefix_default_locale]
      hash  = { domains: [], locales: [], url_redirections: [] }

      unless update_advanced?
        plain -= [:timezone_name, :robots_txt, :cache_enabled, :prefix_default_locale]
        hash.delete(:locales)
        hash.delete(:url_redirections)
      end

      unless point?
        plain -= [:handle, :redirect_to_first_domain, :redirect_to_https, :private_access, :password]
        hash.delete(:domains)
      end

      plain << hash
    end

  end
end
