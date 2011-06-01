module Admin
  class SitemapsController < BaseController

    skip_before_filter :require_admin, :validate_site_membership, :set_locale

    before_filter :require_site

    respond_to :xml

    def show
      @pages = current_site.pages.published
    end

  end
end
