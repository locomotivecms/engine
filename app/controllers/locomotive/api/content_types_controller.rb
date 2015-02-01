module Locomotive
  module Api
    class ContentTypesController < Api::BaseController

      account_required & within_site

      before_filter :load_content_type,  only: [:show, :update, :destroy]
      before_filter :load_content_types, only: [:index]

      def index
        authorize Locomotive::ContentType
        @content_types = @content_types.order_by(:name.asc)
        respond_with @content_types
      end

      def show
        authorize @content_type
        respond_with @content_type
      end

      def create
        authorize Locomotive::ContentType
        @content_type = current_site.content_types.build
        @content_type.from_presenter(params[:content_type]).save
        respond_with @content_type, location: -> { main_app.locomotive_api_content_type_url(@content_type) }
      end

      def update
        authorize @content_type
        @content_type.from_presenter(params[:content_type]).save
        respond_with @content_type, location: main_app.locomotive_api_content_type_url(@content_type)
      end

      def destroy
        authorize @content_type
        @content_type.destroy
        respond_with @content_type, location: -> { main_app.locomotive_api_content_types_url }
      end

      private

      def load_content_type
        @content_type = current_site.content_types.find(params[:id])
      end

      def load_content_types
        @content_types = current_site.content_types
      end

    end
  end
end
