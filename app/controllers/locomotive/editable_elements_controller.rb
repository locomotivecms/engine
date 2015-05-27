module Locomotive
  class EditableElementsController < BaseController

    account_required & within_site

    localized

    before_filter :load_page

    layout 'locomotive/layouts/preview'

    def index
      authorize @page
      respond_with(@page)
    end

    private

    def load_page
      @page = current_site.pages.find(params[:page_id])
    end


  end
end
