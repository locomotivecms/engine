module Locomotive
  class PagesController < BaseController

    sections 'contents'

    localized

    before_filter :back_to_default_site_locale, :only => %w(new create)

    respond_to    :json, :only => [:show, :create, :update, :sort, :get_path]

    def index
      @pages = current_site.all_pages_in_once
      respond_with(@pages)
    end

    def show
      @page = current_site.pages.find(params[:id])
      respond_with @page
    end

    def new
      @page = current_site.pages.build
      respond_with @page
    end

    def create
      @page = current_site.pages.create(params[:page])
      respond_with @page, :location => edit_page_url(@page._id)
    end

    def edit
      @page = current_site.pages.find(params[:id])
      respond_with @page
    end

    def update
      @page = current_site.pages.find(params[:id])
      @page.update_attributes(params[:page])
      respond_with @page, :location => edit_page_url(@page._id)
    end

    def destroy
      @page = current_site.pages.find(params[:id])
      @page.destroy
      respond_with @page
    end

    def sort
      @page = current_site.pages.find(params[:id])
      @page.sort_children!(params[:children])
      respond_with @page
    end

    def get_path
      page = current_site.pages.build(:parent => current_site.pages.find(params[:parent_id]), :slug => params[:slug].permalink).tap do |p|
        p.valid?; p.send(:build_fullpath)
      end
      render :json => { :url => public_page_url(page), :slug => page.slug, :templatized_parent => page.templatized_from_parent? }
    end

  end
end