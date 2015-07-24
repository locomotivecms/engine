module Locomotive
  class DashboardController < BaseController

    account_required & within_site

    def show
      @activities = current_site.activities.order_by(:created_at.desc).page(params[:page]).per(Locomotive.config.ui[:per_page])
      respond_with @activities, layout: !request.xhr?
    end

  end
end
