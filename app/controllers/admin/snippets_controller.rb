module Admin
  class SnippetsController < BaseController
  
    sections 'settings'
  
    def index
      @snippets = current_site.snippets.order_by([[:name, :asc]])
    end
  
  end
end