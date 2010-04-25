class Admin::PagesController < Admin::BaseController
  
  sections 'contents'
  
  def index
    @pages = Page.all
  end
  
  def new
    @page = current_site.pages.build
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