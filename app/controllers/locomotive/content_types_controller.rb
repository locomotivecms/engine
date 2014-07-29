module Locomotive
  class ContentTypesController < BaseController

    sections 'contents'

    before_filter :back_to_default_site_locale, only: %w(new create)
    before_filter :load_content_type, only: [:edit, :update, :destroy]

    respond_to :json, only: [:create, :update, :destroy]

    helper 'Locomotive::Accounts', 'Locomotive::CustomFields'

    def new
      @content_type = current_site.content_types.new
      respond_with @content_type
    end

    def create
      authorize :content_type
      @content_type = current_site.content_types.create(params[:content_type])
      respond_with @content_type, location: edit_content_type_path(@content_type._id)
    end

    def edit
      respond_with @content_type
    end

    def update
      authorize :content_type
      @content_type.update_attributes(params[:content_type])
      respond_with @content_type, location: edit_content_type_path(@content_type._id)
    end

    def destroy
      authorize :content_type
      @content_type.destroy
      respond_with @content_type, location: pages_path
    end

    private

    def load_content_type
      @content_type = current_site.content_types.find(params[:id])
    end

  end
end
