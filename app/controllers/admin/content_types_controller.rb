module Admin
  class ContentTypesController < BaseController
  
    sections 'contents'
      
    def new
      @content_type = current_site.content_types.build
    end
  
    def edit
      @content_type = current_site.content_types.find(params[:id])
    end
  
    def create
      @content_type = current_site.content_types.build(params[:content_type])

      if @content_type.save
        flash_success!
        redirect_to edit_admin_content_type_url(@content_type)
      else
        flash_error!
        render :action => 'new'
      end
    end
  
    def update
      @content_type = current_site.content_types.find(params[:id])
      
      if @content_type.update_attributes(params[:content_type])
        flash_success!
        redirect_to edit_admin_content_type_url(@content_type)
      else
        flash_error!
        render :action => "edit"
      end
    end
  
    def destroy
      @content_type = current_site.content_types.find(params[:id])

      begin
        @content_type.destroy
        flash_success!
      rescue Exception => e
        flash[:error] = e.to_s
      end

      redirect_to admin_content_types_url
    end
      
  end
end