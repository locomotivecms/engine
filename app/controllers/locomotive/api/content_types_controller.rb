module Locomotive
  module Api
    class ContentTypesController < BaseController

      load_and_authorize_resource :class => Locomotive::ContentType

      def index
        @content_types = current_site.content_types.order_by([[:name, :asc]])
        respond_with(@content_types)
      end

      def show
        @content_type = current_site.content_types.find(params[:id])
        respond_with @content_type
      end

      def create
        @content_type = current_site.content_types.create(params[:content_type])
        respond_with @content_type, :location => main_app.locomotive_api_content_types_url
      end

      def update
        @content_type = current_site.content_types.find(params[:id])
        @content_type.update_attributes(params[:content_type])
        respond_with @content_type, :location => main_app.locomotive_api_content_types_url
      end

      def destroy
        @content_type = current_site.content_types.find(params[:id])
        @content_type.destroy
        respond_with @content_type
      end

    end
  end
end
