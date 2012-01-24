module Locomotive
  module Api
    class ContentTypesController < BaseController

      def index
        @content_types = current_site.content_types
        respond_with(@content_types)
      end

      def create
        @content_type = current_site.content_types.create(params[:content_type])
        respond_with @content_type, :location => edit_locomotive_api_content_type_url(@content_type._id)
      end

      def edit
        @content_type = current_site.content_types.find(params[:id])
        respond_with @content_type
      end

      def update
        @content_type = current_site.content_types.find(params[:id])
        @content_type.update_attributes(params[:content_type])
        respond_with @content_type, :location => edit_locomotive_api_content_type_url(@content_type._id)
      end

    end
  end
end
