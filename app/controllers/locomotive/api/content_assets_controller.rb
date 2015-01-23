module Locomotive
  module Api
    class ContentAssetsController < Api::BaseController

      account_required & within_site

      before_filter :load_content_asset, only: [:show, :update, :destroy]
      before_filter :load_content_assets, only: [:index]

      def index
        authorize Locomotive::ContentAsset
        respond_with @content_assets
      end

      def show
        authorize @content_asset
        respond_with @content_asset
      end

      def create
        authorize Locomotive::ContentAsset
        @content_asset = current_site.content_assets.build
        @content_asset.from_presenter(params[:content_asset]).save
        respond_with @content_asset, location: -> { main_app.locomotive_api_content_asset_url(@content_asset) }
      end

      def update
        authorize @content_asset
        @content_asset.from_presenter(params[:content_asset]).save
        respond_with @content_asset, location: main_app.locomotive_api_content_asset_url(@content_asset)
      end

      def destroy
        authorize @content_asset
        @content_asset.destroy
        respond_with @content_asset, location: main_app.locomotive_api_content_assets_url
      end

      private

      def load_content_asset
        @content_asset = self.current_site.content_assets.find(params[:id])
      end

      def load_content_assets
        @content_assets = self.current_site.content_assets
      end

    end
  end
end
