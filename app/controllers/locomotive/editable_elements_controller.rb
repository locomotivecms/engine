module Locomotive
  class EditableElementsController < BaseController

    account_required & within_site

    localized

    before_filter :load_page
    after_filter  :store_location_if_content_entry

    layout :editable_elements_layout

    def index
      authorize @page

      @editable_elements = parsing_service.find_or_create_editable_elements(@page)

      respond_with(@page) do |format|
        format.html { render_index }
      end
    end

    def update_all
      authorize @page, :update?

      @editable_elements = persisting_service.update_all(page_params[:editable_elements_attributes].values)

      respond_with(@page, notice: t(:notice, scope: 'flash.locomotive.pages.update'), location: editable_elements_path(current_site, @page)) do |format|
        format.html { render_index }
      end
    end

    private

    def editable_elements_layout
      @page.default_response_type? ? 'locomotive/layouts/live_editing' : '/locomotive/layouts/application'
    end

    def load_page
      @page = current_site.pages.find(params[:page_id])
    end

    def page_params
      params.require(:page).permit(editable_elements_attributes: [:id, :_id, :page_id, :source, :remove_source, :remote_source_url, :content])
    end

    def render_index
      if @editable_elements
        @editable_elements_by_block = parsing_service.group_and_sort_editable_elements(@editable_elements)
        @blocks = parsing_service.blocks_from_grouped_editable_elements(@editable_elements_by_block)
      end

      @content_entry = @page.content_type.entries.find(params[:content_entry_id]) if params[:content_entry_id]

      if request.xhr?
        render partial: 'edit'
      else
        render @page.default_response_type? ? 'index' : 'index_without_preview'
      end
    end

    def parsing_service
      @parsing_service ||= Locomotive::PageParsingService.new(current_site, current_content_locale)
    end

    def persisting_service
      @persisting_service ||= Locomotive::EditableElementService.new(current_site, current_locomotive_account)
    end

    def store_location_if_content_entry
      store_location if @content_entry
    end

  end
end
