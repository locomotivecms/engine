module Locomotive
  module Api
    class ThemeAssetsController < BaseController

      include Locomotive::Routing::SiteDispatcher

      def index
        @theme_assets = current_site.theme_assets.all
        respond_with(@theme_assets)
      end

      def create
        @theme_asset = current_site.theme_assets.create(params[:theme_asset])
        respond_with @theme_asset, :location => edit_theme_asset_url(@theme_asset._id)
      end

      def update
        @theme_asset = current_site.theme_assets.find(params[:id])
        @theme_asset.update_attributes(params[:theme_asset])
        respond_with @theme_asset, :location => edit_theme_asset_url(@theme_asset._id)
      end

    end
  end
end
