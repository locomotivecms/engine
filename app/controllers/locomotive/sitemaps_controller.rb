module Locomotive
  class SitemapsController < BaseController

    skip_before_filter :require_account, :validate_site_membership, :set_locale

    before_filter :require_site

    respond_to :xml

    skip_load_and_authorize_resource

    def show
      @pages = current_site.pages.published
      respond_with @pages
    end

  end
end
