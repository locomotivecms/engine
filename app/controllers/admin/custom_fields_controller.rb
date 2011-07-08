module Admin
  class CustomFieldsController < BaseController

    layout false

    before_filter :set_parent_and_fields

    skip_load_and_authorize_resource

    def edit
      @field = @fields.find(params[:id])
      render :action => "edit_#{@field.kind.downcase}"
    end

    def update
      @field = @fields.find(params[:id])

      if @field.update_attributes(params[:custom_field])
        render :json => @field.to_json
      else
        render :json => { :error => t('flash.admin.custom_fields.update.alert') }
      end
    end

    protected

    def set_parent_and_fields
      @parent = current_site.content_types.where(:slug => params[:slug]).first
      @fields = @parent.content_custom_fields
    end

  end
end
