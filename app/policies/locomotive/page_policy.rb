module Locomotive
  class PagePolicy < ApplicationPolicy

    def index?
      site_staff?
    end

    def new?
      site_staff?
    end

    def edit?
      site_staff?
    end

    def create?
      site_staff? && !membership.visitor?
    end

    def update?
      site_staff? && !membership.visitor?
    end

    def destroy?
      site_staff? && !@resource.index_or_not_found? && !membership.visitor?
    end

    def show?
      site_admin_or_designer? || !@resource.hidden?
    end

    def permitted_attributes
      attributes = [:title, :layout_id, :slug, :parent_id, :listed, :published, :redirect, :redirect_url, :redirect_type, :seo_title, :meta_description, :meta_keywords]
      if site_admin_or_designer?
        attributes += [:cache_enabled, :cache_control, :cache_vary]
        attributes += [:handle]
      end
      attributes
    end

  end
end
