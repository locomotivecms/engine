module Admin
  class PagePartsController < BaseController
  
    layout nil

    def index
      parts = current_site.layouts.find(params[:layout_id]).parts
      render :json => { :parts => parts }
    end
  
  end
end