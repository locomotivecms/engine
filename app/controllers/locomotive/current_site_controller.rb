module Locomotive
  class CurrentSiteController < BaseController

    account_required & within_site

    localized

    before_action :load_site

    helper Locomotive::SitesHelper

    before_action :ensure_domains_list, only: :update
    before_action :ensure_url_redirections, only: :update

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

    def new_url_redirection
      if params[:url_redirection].present? && params[:url_redirection].include?(' ')
        source, target = params[:url_redirection].split(' ')
        render partial: 'url_redirection', locals: {
          url_redirection: { 'source' => source, 'target' => target }
        }
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
      @service ||= Locomotive::SiteService.new(current_locomotive_account)
    end

    def ensure_domains_list
      params[:site][:domains] = [] unless params[:site][:domains]
    end

    def ensure_url_redirections
      params[:site][:url_redirections] = [] unless params[:site][:url_redirections]
    end

  end
end
