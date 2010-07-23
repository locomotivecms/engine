module Admin
  class CustomFieldsController < BaseController

    layout false

    before_filter :set_parent_and_fields

    def edit
      @field = @fields.find(params[:id])
      render :action => "edit_#{@field.kind.downcase}"
    end

    def update
      @field = @fields.find(params[:id])
      @field.updated_at = Time.now # forces mongoid to save the object

      params[:custom_field][:category_items_attributes].delete('-1')

      if @field.update_attributes(params[:custom_field])
        render :json => @field.attributes
      else
        render :json => { :error => t('flash.admin.custom_fields.update.alert') }
      end
    end

    protected

    def set_parent_and_fields
      if params[:parent] == 'asset_collection'
        @parent = current_site.asset_collections.where(:slug => params[:slug]).first
        @fields = @parent.asset_custom_fields
      else
        @parent = current_site.content_types.where(:slug => params[:slug]).first
        @fields = @parent.content_custom_fields
      end
    end

  end
end
