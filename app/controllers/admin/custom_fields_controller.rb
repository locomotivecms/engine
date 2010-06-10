module Admin
  class CustomFieldsController < BaseController
   
    layout false
    
    before_filter :set_content_type
    
    def edit
      @field = @content_type.content_custom_fields.find(params[:id])
      render :action => "edit_#{@field.kind.downcase}"
    end
    
    def update
      @field = @content_type.content_custom_fields.find(params[:id])
      @field.updated_at = Time.now # forces mongoid to save the object
      
      params[:custom_field][:category_items_attributes].delete('-1')
      
      if @field.update_attributes(params[:custom_field])
        render :json => @field.attributes
      else
        render :json => { :error => translate_flash_msg(:successful) }
      end
    end
    
    protected
    
    def set_content_type
      @content_type = current_site.content_types.where(:slug => params[:slug]).first
    end
    
  end
end