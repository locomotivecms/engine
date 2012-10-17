module Locomotive
  module Api
    class ThemeAssetsController < BaseController
      load_and_authorize_resource :class => Locomotive::ThemeAsset

      def index
        @theme_assets = current_site.theme_assets.all
        respond_with(@theme_assets)
      end

      def show
        @theme_asset = current_site.theme_assets.find(params[:id])
        respond_with @theme_asset
      end

      def create
        @theme_asset = current_site.theme_assets.create(params[:theme_asset])
        respond_with @theme_asset, :location => main_app.locomotive_api_theme_assets_url
      end

      def update
        @theme_asset = current_site.theme_assets.find(params[:id])
        @theme_asset.update_attributes(params[:theme_asset])
        respond_with @theme_asset, :location => main_app.locomotive_api_theme_assets_url
      end

      def destroy
        @theme_asset = current_site.theme_assets.find(params[:id])
        @theme_asset.destroy
        respond_with @theme_asset
      end

    end
  end
end
