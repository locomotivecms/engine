module Locomotive
  class PageContentController < BaseController

    account_required & within_site

    localized

    before_action :load_page

    layout :editable_elements_layout

    def edit
      authorize @page

      @sections = parsing_service.sections(@page)
      @preview_path = preview_path(current_site) + '/' + current_site.localized_page_fullpath(@page,current_content_locale)
      respond_with(@page) do |format|
        format.html { render 'edit' }
      end
    end

    def update
      binding.pry
      authorize @page


    end

    def load_page
      @page = current_site.pages.find(params[:page_id])
    end

    def parsing_service
      @parsing_service ||= Locomotive::PageParsingService.new(current_site, current_content_locale)
    end

    def render_index
        render @page.default_response_type? ? 'index' : 'index_without_preview'
    end

    def editable_elements_layout
      @page.default_response_type? ? 'locomotive/layouts/live_editing' : '/locomotive/layouts/application'
    end
  end
end