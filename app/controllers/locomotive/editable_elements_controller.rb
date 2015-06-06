module Locomotive
  class EditableElementsController < BaseController

    account_required & within_site

    localized

    before_filter :load_page

    layout 'locomotive/layouts/live_editing'

    def index
      authorize @page

      @editable_elements = service.find_or_create_editable_elements(@page)

      respond_with(@page) do |format|
        format.html { render_index }
      end
    end

    def update_all
      logger.debug 'youpi...'

      @editable_elements = service.find_or_create_editable_elements(@page)

      respond_with(@page, notice: "Crazy!!!") do |format|
        format.html { render_index }
      end
    end

    private

    def render_index
      if request.xhr?
        render partial: 'form'
      else
        render 'index'
      end
    end

    def load_page
      @page = current_site.pages.find(params[:page_id])
    end

    def service
      @service ||= Locomotive::PageParsingService.new(current_site, current_content_locale)
    end

  end
end
