module Locomotive
  class DashboardController < BaseController

    account_required & within_site

    def show
      # render layout: false
    end

  end
end
