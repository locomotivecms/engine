module Admin
  class PagesController < BaseController

    sections 'contents'

    respond_to :json, :only => [:update, :sort, :get_path]

    def index
      @pages = current_site.all_pages_in_once
    end

    def new
      @page = current_site.pages.build
    end

    def update
      update! do |success, failure|
        success.json do
          render :json => {
            :notice => t('flash.admin.pages.update.notice'),
            :editable_elements => @page.template_changed ?
              render_to_string(:partial => 'admin/pages/editable_elements.html.haml') : ''
          }
        end
      end
    end

    def sort
      @page = current_site.pages.find(params[:id])
      @page.sort_children!(params[:children])

      respond_with @page
    end

    def get_path
      page = current_site.pages.build(:parent => current_site.pages.find(params[:parent_id]), :slug => params[:slug].slugify)

      render :json => { :url => page_url(page), :slug => page.slug }
    end

  end
end
