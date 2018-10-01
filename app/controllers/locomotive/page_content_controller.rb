module Locomotive
  class PageContentController < BaseController

    account_required & within_site

    localized

    before_action :load_page
    before_action :only_if_sections

    layout :editable_elements_layout

    respond_to :json, only: [:edit, :update]

    helper Locomotive::ContentEntriesHelper

    def edit
      authorize @page

      @section_definitions    = current_site.sections.pluck(:slug, :definition).map { |document|
        { 'type' => document[0] }.merge(document[1])
      }
      @editable_content       = parsing_service.find_all_elements(@page)
      @sections               = @editable_content[:sections]
      @editable_elements      = @editable_content[:elements]
    end

    def update
      authorize @page

      persisting_service.save(site_params, page_params)
    end

    private

    # load the page based on the page_id param. If this param includes a dash,
    # that means we've got a templatized page with one of the content entries.
    # The id of the content entry can also come from a param.
    # Either ways, we load both the page and the content entry.
    def load_page
      page_id, content_entry_id = params[:page_id].split('-')
      content_entry_id ||= params[:content_entry_id]

      @page = current_site.pages.find(page_id).tap do |page|
        if page.templatized? &&
          page.content_entry = content_entry_id ?
          page.content_type.entries.find(content_entry_id) :
          page.fetch_target_entries.first

        end
      end
    end

    def parsing_service
      @parsing_service ||= Locomotive::PageParsingService.new(current_site, current_content_locale)
    end

    def persisting_service
      @persisting_service ||= Locomotive::EditorService.new(current_site, current_locomotive_account, @page)
    end

    def editable_elements_layout
      @page.default_response_type? ? 'locomotive/layouts/editor' : '/locomotive/layouts/application'
    end

    def site_params
      params.require(:site).permit(:sections_content)
    end

    def page_params
      params.require(:page).permit(:title, :slug, :published, :listed,
        :seo_title, :meta_keywords, :meta_description,
        :sections_content, :sections_dropzone_content)
    end

    def only_if_sections
      redirect_to editable_elements_path(current_site, @page) if current_site.sections.count == 0
    end

  end
end
