module Locomotive
  class SitePolicy < ApplicationPolicy

    class Scope < ApplicationPolicy::Scope

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

    def edit?
      super_admin? || site_staff?
    end

    def new
      !account.visitor?
    end

    def create?
      !account.visitor?
    end

    def update?
      super_admin? || site_staff? && !membership.visitor?
    end

    def destroy?
      super_admin? || site_admin?
    end

    def point?
      !persisted? || super_admin? || site_admin?
    end

    def update_advanced?
      super_admin? || site_admin?
    end

    def show_developers_documentation?
      super_admin? || site_admin?
    end

    def permitted_attributes
      plain = [
        :name, :handle, :picture, :remove_picture, :seo_title, :meta_keywords, :meta_description, :robots_txt, :maximum_uploaded_file_size,
        :timezone_name, :timezone,
        :cache_enabled, :cache_control, :cache_vary,
        :asset_host, :redirect_to_first_domain, :redirect_to_https,
        :private_access, :password, :prefix_default_locale, :bypass_browser_locale
      ]
      hash  = { domains: [], locales: [], url_redirections: [] }

      if persisted? && !update_advanced?
        plain -= [:timezone_name, :timezone, :robots_txt, :cache_enabled, :cache_control, :cache_vary, :prefix_default_locale, :bypass_browser_locale, :asset_host, :maximum_uploaded_file_size]
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
