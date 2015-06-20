module Locomotive
  class EditableElementsController < BaseController

    account_required & within_site

    localized

    before_filter :load_page

    layout 'locomotive/layouts/live_editing'

    def index
      authorize @page

      @editable_elements = parsing_service.find_or_create_editable_elements(@page)

      respond_with(@page) do |format|
        format.html { render_index }
      end
    end

    def update_all
      authorize @page, :update?

      persisting_service.update_all(page_params[:editable_elements_attributes])

      respond_with(@page, notice: t(:notice, scope: 'flash.locomotive.pages.update'), location: editable_elements_path(current_site, @page)) do |format|
        format.js { render nothing: true }
      end
    end

    private

    def load_page
      @page = current_site.pages.find(params[:page_id])
    end

    def page_params
      params.require(:page).permit(editable_elements_attributes: [:id, :page_id, :source, :remove_source, :remote_source_url, :content])
    end

    def parsing_service
      @parsing_service ||= Locomotive::PageParsingService.new(current_site, current_content_locale)
    end

    def persisting_service
      @persisting_service ||= Locomotive::EditableElementService.new(current_site, current_locomotive_account)
    end

    def render_index
      if request.xhr?
        render partial: 'edit'
      else
        render 'index'
      end
    end

  end
end
