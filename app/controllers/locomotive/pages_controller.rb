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
      respond_with @page
    end

    def update
      authorize @page
      service.update(@page, page_params)
      respond_with @page, location: edit_page_path(current_site, @page)
    end

    def destroy
      authorize @page
      @page.destroy
      respond_with @page, location: pages_path(current_site)
    end

    def sort
      authorize @page, :update?
      @page.sort_children!(params.require(:children))
      respond_with @page, location: edit_page_path(current_site, @page)
    end

    private

    def load_page
      @page = current_site.pages.find(params[:id])
    end

    def page_params
      params.require(:page).permit(:title, :parent_id, :listed, :published)
    end

    def service
      @service ||= Locomotive::PageService.new(current_site)
    end

  end
end
