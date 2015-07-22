module Locomotive
  class DashboardController < BaseController

    account_required & within_site

    def show
      @activities = current_site.activities.order_by(:created_at.desc)
      respond_with @activities
    end

  end
end
