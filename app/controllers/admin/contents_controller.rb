module Admin
  class ContentsController < BaseController
  
    sections 'contents'
    
    before_filter :set_content_type    
  
    def index
      @contents = @content_type.list_or_group_contents
    end
  
    def new
      @content = @content_type.contents.build
    end
  
    def edit
      @content = @content_type.contents.find(params[:id])
    end
  
    def create
      @content = @content_type.contents.build(params[:content_instance])

      if @content.save
        flash_success!
        redirect_to edit_admin_content_url(@content_type.slug, @content)
      else
        flash_error!
        render :action => 'new'
      end
    end
  
    def update
      @content = @content_type.contents.find(params[:id])
      
      if @content.update_attributes(params[:content_instance])
        flash_success!
        redirect_to edit_admin_content_url(@content_type.slug, @content)
      else
        flash_error!
        render :action => "edit"
      end
    end
    
    def sort
      @content_type.sort_contents!(params[:order])
      
      flash_success!
      
      redirect_to admin_contents_url(@content_type.slug)
    end    
  
    def destroy
      @content = @content_type.contents.find(params[:id])

      begin
        @content.destroy
        flash_success!
      rescue Exception => e
        flash[:error] = e.to_s
      end

      redirect_to admin_contents_url(@content_type.slug)
    end
  
    protected
  
    def set_content_type
      @content_type = current_site.content_types.where(:slug => params[:slug]).first
    end
  
  end
end