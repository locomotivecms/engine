module Locomotive
  class ContentAssetsController < BaseController

    respond_to :json, only: [:index, :create, :destroy]

    def index
      @content_assets = current_site.content_assets
        .ordered
        .by_content_types(params[:types])
        .by_filename(params[:query])
        .page(params[:page] || 1).per(params[:per_page] || Locomotive.config.ui[:per_page])
      respond_with(@content_assets)
    end

    def create
      @content_asset = current_site.content_assets.create(params[:content_asset])
      respond_with @content_asset
    end

    def destroy
      @content_asset = current_site.content_assets.find(params[:id])
      @content_asset.destroy
      respond_with @content_asset
    end

  end
end