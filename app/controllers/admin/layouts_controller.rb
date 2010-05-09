class Admin::LayoutsController < Admin::BaseController
  
  sections 'settings'
  
  def index
    @layouts = current_site.layouts
  end
    
  def new
    @layout = current_site.layouts.build
  end
  
  def edit
    @layout = current_site.layouts.find(params[:id])
  end
  
  def create
    @layout = current_site.layouts.build(params[:layout])

    if @layout.save
      flash_success!
      redirect_to edit_admin_layout_url(@layout)
    else
      flash_error!
      render :action => 'new'
    end
  end
  
  def update
    @layout = current_site.layouts.find(params[:id])
      
    if @layout.update_attributes(params[:layout])
      flash_success!
      redirect_to edit_admin_layout_url(@layout)
    else
      flash_error!
      render :action => "edit"
    end
  end
  
  def destroy
    @layout = current_site.layouts.find(params[:id])

    begin
      @layout.destroy
      flash_success!
    rescue Exception => e
      flash[:error] = e.to_s
    end

    redirect_to admin_layouts_url
  end
  
end