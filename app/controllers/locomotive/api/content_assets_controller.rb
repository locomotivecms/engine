module Locomotive
  module Api
    class ContentAssetsController < BaseController

      before_filter :load_content_asset, only: [:show, :update, :destroy]
      before_filter :load_content_assets, only: [:index]

      def index
        respond_with(@content_assets)
      end

      def show
        respond_with(@content_asset)
      end

      def create
        authorize :content_asset
        @content_asset = ContentAsset.new(params[:content_asset])
        @content_asset.from_presenter(params[:content_asset])
        @content_asset.save
        respond_with @content_asset, location: main_app.locomotive_api_content_assets_url
      end

      def update
        authorize :content_asset
        @content_asset.from_presenter(params[:content_asset])
        @content_asset.save
        respond_with @content_asset, location: main_app.locomotive_api_content_assets_url
      end

      def destroy
        authorize :content_asset
        @content_asset.destroy
        respond_with @content_asset
      end

      private

      def load_content_asset
        @content_asset = self.current_site.content_assets.find params[:id]
      end

      def load_content_assets
        @content_assets = self.current_site.content_assets
      end

    end
  end
end
