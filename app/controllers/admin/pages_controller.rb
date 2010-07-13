module Admin
  class PagesController < BaseController
  
    sections 'contents'
    
    respond_to :json, :only => [:update, :sort]
  
    def index
      @pages = current_site.pages.roots
    end
  
    def new
      @page = current_site.pages.build
      @page.parts << PagePart.build_body_part
    end
    
    def sort
      @page = current_site.pages.find(params[:id])
      @page.sort_children!(params[:children])
    
      respond_with @page
    end
    
    def get_path
      page = current_site.pages.build(:parent => current_site.pages.find(params[:parent_id]), :slug => params[:slug].slugify)
    
      render :json => { :url => page.url, :slug => page.slug }
    end
    
  end
end

# DEPRECATED

# def edit
#   @page = current_site.pages.find(params[:id])  
# end
#
# def create
#   @page = current_site.pages.create(params[:page])
#   
#   respond_with(@page, :location => (edit_admin_page_url(@page) rescue nil))
# end
#   
# def update
#   @page = current_site.pages.find(params[:id])
#   @page.update_attributes(params[:page])
#   
#   respond_with(@page, :location => edit_admin_page_url(@page))
# end
#
# def destroy
#   @page = current_site.pages.find(params[:id])
#   @page.destroy
#   
#   respond_with(@page, :alert => @page.errors.full_messages.first, :location => admin_pages_url)
# end