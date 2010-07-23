module Admin
  class LayoutsController < BaseController

    sections 'settings'

    respond_to :json, :only => :update

    def index
      @layouts = current_site.layouts.order_by([[:name, :asc]])
    end

  end
end
