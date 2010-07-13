module Admin
  class LayoutsController < BaseController
  
    sections 'settings'
  
    def index
      @layouts = current_site.layouts.order_by([[:name, :asc]])
    end
  
  end
end