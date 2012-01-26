module Locomotive
  class ContentTypesController < BaseController

    sections 'contents'

    before_filter :back_to_default_site_locale, :only => %w(new create)

    respond_to :json, :only => [:create, :update, :destroy]

    helper 'Locomotive::Accounts', 'Locomotive::CustomFields'

    def new
      @content_type = current_site.content_types.new
      respond_with @content_type
    end

    def create
      @content_type = current_site.content_types.create(params[:content_type])
      respond_with @content_type, :location => edit_content_type_url(@content_type._id)
    end

    def edit
      @content_type = current_site.content_types.find(params[:id])
      respond_with @content_type
    end

    def update
      @content_type = current_site.content_types.find(params[:id])
      @content_type.update_attributes(params[:content_type])
      respond_with @content_type, :location => edit_content_type_url(@content_type._id)
    end

    def destroy
      @content_type = current_site.content_types.find(params[:id])
      @content_type.destroy
      respond_with @content_type, :location => pages_url
    end

  end
end
