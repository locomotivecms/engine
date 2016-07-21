module Locomotive
  class ThemesController < BaseController

    account_required & within_site

    def show
      authorize(current_site, :update?)
    end

    def activate
      authorize(current_site, :update?)
      current_site.activate_theme(params[:site_id])
    end

  end
end
