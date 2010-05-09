class Admin::PagesController < Admin::BaseController
  
  sections 'contents'
  
  def index
    @pages = current_site.pages.roots
  end
  
  def new
    @page = current_site.pages.build
    @page.parts << PagePart.build_body_part
  end
  
  def edit
    @page = current_site.pages.find(params[:id])  
  end
  
  def create
    @page = current_site.pages.build(params[:page])

    if @page.save
      flash_success!
      redirect_to edit_admin_page_url(@page)
    else
      flash_error!
      render :action => 'new'
    end
  end
  
  def update
    @page = current_site.pages.find(params[:id])
      
    if @page.update_attributes(params[:page])
      flash_success!
      redirect_to edit_admin_page_url(@page)
    else
      flash_error!
      render :action => "edit"
    end
  end
  
  def sort
    @page = current_site.pages.find(params[:id])
    @page.sort_children!(params[:children])
    
    render :json => { :message => translate_flash_msg(:successful) }
  end
  
  def get_path
    page = current_site.pages.build(:parent => current_site.pages.find(params[:parent_id]), :slug => params[:slug].slugify)
    
    render :json => { :url => page.url, :slug => page.slug }
  end
  
  def destroy
    @page = current_site.pages.find(params[:id])

    begin
      @page.destroy
      flash_success!
    rescue Exception => e
      flash[:error] = e.to_s
    end

    redirect_to admin_pages_url
  end
  
end