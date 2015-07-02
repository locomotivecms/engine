module Locomotive
  class CurrentSiteController < BaseController

    account_required & within_site

    localized

    before_filter :load_site

    helper Locomotive::SitesHelper

    before_filter :ensure_domains_list, only: :update

    def edit
      authorize @site
      respond_with @site
    end

    def update
      authorize @site
      service.update(@site, site_params)
      respond_with @site, location: -> { edit_current_site_path(current_site) }
    end

    def destroy
      authorize @site
      @site.destroy
      respond_with @site, location: sites_path
    end

    def new_domain
      if params[:domain].present?
        render partial: 'domain', locals: { domain: params[:domain] }
      else
        head :unprocessable_entity
      end
    end

    def new_locale
      if params[:locale].present?
        render partial: 'locale', locals: { locale: params[:locale] }
      else
        head :unprocessable_entity
      end
    end

    private

    def load_site
      @site = current_site
    end

    def site_params
      params.require(:site).permit(*policy(@site || Site).permitted_attributes)
    end

    def service
      @service ||= Locomotive::SiteService.new(locomotive_current_account)
    end

    def ensure_domains_list
      params[:site][:domains] = [] unless params[:site][:domains]
    end

  end
end
