module Locomotive
  class PagesController < BaseController

    sections 'contents'

    localized

    before_filter :back_to_default_site_locale, only: %w(new create)

    before_filter :load_page, only: [:show, :edit, :update, :sort, :destroy]

    respond_to :json, only: [:show, :create, :update, :sort, :get_path]

    def index
      authorize Page
      @pages = current_site.all_pages_in_once
      respond_with(@pages)
    end

    def show
      authorize @page
      respond_with @page
    end

    def new
      authorize Page
      @page = current_site.pages.build
      respond_with @page
    end

    def create
      authorize Page
      @page = current_site.pages.create(params[:page])
      respond_with @page, location: edit_page_path(@page._id)
    end

    def edit
      authorize @page
      respond_with @page
    end

    def update
      authorize @page
      @page.update_attributes(params[:page])
      respond_with @page, location: edit_page_path(@page._id)
    end

    def destroy
      authorize @page
      @page.destroy
      respond_with @page
    end

    def sort
      authorize @page, :update?
      @page.sort_children!(params[:children])
      respond_with @page
    end

    def get_path
      page = current_site.pages.build(parent: current_site.pages.find(params[:parent_id]), slug: params[:slug].permalink).tap do |p|
        p.valid?; p.send(:build_fullpath)
      end
      render json: {
        url:                public_page_url(page, locale: current_content_locale),
        slug:               page.slug,
        templatized_parent: page.templatized_from_parent?
      }
    end

    private

    def load_page
      @page = current_site.pages.find(params[:id])
    end

  end
end
