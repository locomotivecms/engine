module Locomotive
  class CurrentSiteMetafieldsController < BaseController

    account_required & within_site

    localized

    before_filter :load_site

    helper Locomotive::SitesHelper

    def index
      authorize @site
      respond_with(@site)
    end

    def update_all
      authorize @site, :update?
      service.update_all(params[:site][:metafields])
      respond_with @site, location: -> { current_site_metafields_path(current_site) }
    end

    private

    def load_site
      @site = current_site
    end

    def service
      @service ||= Locomotive::SiteMetafieldsService.new(current_site, current_locomotive_account)
    end

  end
end
