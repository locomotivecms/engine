module Locomotive
  class PagesController < BaseController

    account_required & within_site

    localized

    before_filter :back_to_default_site_locale, only: %w(new create)

    before_filter :load_page, only: [:edit, :update, :sort, :destroy]

    respond_to :json, only: [:sort]

    def new
      authorize Page
      @page = current_site.pages.build
      respond_with @page
    end

    def create
      authorize Page
      @page = service.create(page_params)
      respond_with @page, location: -> { edit_page_path(current_site, @page) }
    end

    def edit
      authorize @page
      @page.find_layout
      respond_with @page
    end

    def update
      authorize @page
      service.update(@page, page_params)
      respond_with @page, location: edit_page_path(current_site, @page)
    end

    def destroy
      authorize @page
      service.destroy(@page)
      respond_with @page, location: editable_elements_path(current_site, current_site.pages.root.first)
    end

    def sort
      authorize @page, :update?
      service.sort(@page, params.require(:children))
      respond_with @page, location: edit_page_path(current_site, @page)
    end

    private

    def load_page
      @page = current_site.pages.find(params[:id])
    end

    def page_params
      params.require(:page).permit(*policy(@page || Page).permitted_attributes)
    end

    def service
      @service ||= Locomotive::PageService.new(current_site, current_locomotive_account)
    end

  end
end
