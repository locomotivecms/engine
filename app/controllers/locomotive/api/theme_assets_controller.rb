module Locomotive
  module Api
    class ThemeAssetsController < BaseController

      load_and_authorize_resource class: Locomotive::Translation, through: :current_site

      def index
        respond_with(@theme_assets)
      end

      def show
        respond_with @theme_asset
      end

      def create
        @theme_asset.from_presenter(params[:theme_asset])
        @theme_asset.save
        respond_with @theme_asset, location: main_app.locomotive_api_theme_assets_url
      end

      def update
        @theme_asset.from_presenter(params[:theme_asset])
        @theme_asset.save
        respond_with @theme_asset, location: main_app.locomotive_api_theme_assets_url
      end

      def destroy
        @theme_asset.destroy
        respond_with @theme_asset
      end

    end
  end
end
