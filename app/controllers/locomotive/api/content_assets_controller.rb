module Locomotive
  module Api
    class ContentAssetsController < BaseController

      def index
        @content_assets = current_site.content_assets
        respond_with(@content_assets)
      end

      def create
        @content_asset = current_site.content_assets.create(params[:content_asset])
        respond_with @content_asset, :location => main_app.locomotive_api_content_assets_url
      end

      def update
        @content_asset = current_site.content_assets.find(params[:id])
        @content_asset.update_attributes(params[:content_asset])
        respond_with @content_asset, :location => main_app.locomotive_api_content_assets_url
      end

    end
  end
end
