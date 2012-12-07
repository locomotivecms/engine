module Locomotive
  module Api
    class ContentTypesController < BaseController

      load_and_authorize_resource class: Locomotive::ContentType, through: :current_site

      def index
        @content_types = @content_types.order_by([[:name, :asc]])
        respond_with(@content_types)
      end

      def show
        respond_with @content_type
      end

      def create
        @content_type.from_presenter(params[:content_type])
        @content_type.save
        respond_with @content_type, location: main_app.locomotive_api_content_types_url
      end

      def update
        @content_type.from_presenter(params[:content_type])
        @content_type.save
        respond_with @content_type, location: main_app.locomotive_api_content_types_url
      end

      def destroy
        @content_type.destroy
        respond_with @content_type
      end

    end
  end
end
