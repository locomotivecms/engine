module Admin
  class SnippetsController < BaseController

    sections 'settings'

    respond_to :json, :only => :update

    def index
      @snippets = current_site.snippets.order_by([[:name, :asc]])
    end

  end
end
