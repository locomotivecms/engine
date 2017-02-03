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
      site_staff? && !@resource.index_or_not_found?
    end

    def show?
      site_admin_or_designer? || !@resource.hidden?
    end

    def permitted_attributes
      attributes = [:title, :layout_id, :slug, :parent_id, :listed, :published, :redirect, :redirect_url, :redirect_type, :seo_title, :meta_description, :meta_keywords, :cache_enabled]
      attributes += [:handle] if site_admin_or_designer?
      attributes
    end

  end
end
