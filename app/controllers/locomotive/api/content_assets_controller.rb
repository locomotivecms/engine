module Locomotive
  module Api
    class ContentAssetsController < BaseController

      before_filter :load_content_asset, only: [:show, :update, :destroy]

      def index
        @content_assets = current_site.content_assets
        respond_with(@content_assets)
      end

      def show
        ApplicationPolicy.new(self.current_locomotive_account, self.current_site).show?
        respond_with(@content_asset)
      end

      def create
        @content_asset = ContentAsset.new(params[:content_asset])
        ApplicationPolicy.new(self.current_locomotive_account, self.current_site).create?
        @content_asset.from_presenter(params[:content_asset])
        @content_asset.save
        respond_with @content_asset, location: main_app.locomotive_api_content_assets_url
      end

      def update
        ApplicationPolicy.new(self.current_locomotive_account, self.current_site).update?
        @content_asset.from_presenter(params[:content_asset])
        @content_asset.save
        respond_with @content_asset, location: main_app.locomotive_api_content_assets_url
      end

      def destroy
        ApplicationPolicy.new(self.current_locomotive_account, self.current_site).destroy?
        @content_asset.destroy
        respond_with @content_asset
      end

      private

      def load_content_asset
        @content_asset = ContentAsset.find params[:id]
      end

    end
  end
end
