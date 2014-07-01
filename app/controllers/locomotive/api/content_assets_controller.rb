module Locomotive
  module Api
    class ContentAssetsController < BaseController

      include Concerns::LoadResource

      def index
        respond_with(@content_assets)
      end

      def show
        respond_with(@content_asset)
      end

      def create
        @content_asset.from_presenter(params[:content_asset])
        @content_asset.save
        respond_with @content_asset, location: main_app.locomotive_api_content_assets_url
      end

      def update
        @content_asset.from_presenter(params[:content_asset])
        @content_asset.save
        respond_with @content_asset, location: main_app.locomotive_api_content_assets_url
      end

      def destroy
        @content_asset.destroy
        respond_with @content_asset
      end

    end
  end
end
