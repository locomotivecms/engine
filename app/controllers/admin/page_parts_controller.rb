module Admin
  class PagePartsController < BaseController

    layout nil

    respond_to :json

    def index
      parts = current_site.layouts.find(params[:layout_id]).parts

      respond_with parts.collect(&:attributes)
    end

  end
end
