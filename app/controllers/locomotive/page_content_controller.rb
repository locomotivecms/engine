module Locomotive
  class PageContentController < BaseController

    account_required & within_site

    localized

    before_action :load_page

    layout :editable_elements_layout

    respond_to :json, only: :update

    def edit
      authorize @page

      @section_definitions    = current_site.sections.pluck(:slug, :definition).map { |document|
        { 'type' => document[0] }.merge(document[1])
      }
      @editable_content       = parsing_service.find_all_elements(@page)
      @static_section_names   = @editable_content[:sections]

      # TODO: move to the helper
      @preview_path = [
        preview_path(current_site),
        params[:preview_path] || current_site.localized_page_fullpath(@page, current_content_locale)
      ].join('/')

      respond_with(@page) do |format|
        format.html { render 'edit' }
      end
    end

    def update
      authorize @page

      persisting_service.save(site_params, page_params)

      respond_to do |format|
        format.json do
          if current_site.valid? && @page.valid?
            render json: { success: true }
          else
            render json: {
              errors: {
                site: current_site.errors.to_json, page: @page.errors.to_json
              }
            }
          end
        end
      end
    end

    private

    def load_page
      @page = current_site.pages.find(params[:page_id])
    end

    def parsing_service
      @parsing_service ||= Locomotive::PageParsingService.new(current_site, current_content_locale)
    end

    def persisting_service
      @persisting_service ||= Locomotive::EditorService.new(current_site, current_locomotive_account, @page)
    end

    def editable_elements_layout
      @page.default_response_type? ? 'locomotive/layouts/live_editing' : '/locomotive/layouts/application'
    end

    def site_params
      params.require(:site).permit(:sections_content)
    end

    def page_params
      params.require(:page).permit(:sections_content)
    end

  end
end
