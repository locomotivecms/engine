module Locomotive
  class DashboardController < BaseController

    skip_load_and_authorize_resource

    sections :dashboard

    def show
    end

  end
end