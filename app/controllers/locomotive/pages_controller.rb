module Locomotive
  class PagesController < BaseController

    sections 'contents'

    respond_to  :json, :only => [:update, :sort, :get_path]

    def index
      @pages = current_site.all_pages_in_once
      respond_with(@pages)
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
      respond_with @page do |format|
        format.html { redirect_to edit_page_url(@page._id) }
        format.json do
          render :json => {
            :notice => t('flash.locomotive.pages.update.notice'),
            :editable_elements => @page.template_changed ?
              render_to_string(:partial => 'locomotive/pages/editable_elements.html.haml') : ''
          }
        end
      end
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
      page = current_site.pages.build(:parent => current_site.pages.find(params[:parent_id]), :slug => params[:slug].permalink)

      render :json => { :url => public_page_url(page), :slug => page.slug }
    end

  end
end