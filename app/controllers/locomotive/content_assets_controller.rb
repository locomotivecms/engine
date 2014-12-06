module Locomotive
  class ContentAssetsController < BaseController

    respond_to :json, only: [:index, :create, :destroy]

    before_filter :load_content_asset,  only: [:destroy]
    before_filter :load_content_assets, only: [:index]

    def index
      authorize Locomotive::ContentAsset
      @content_assets = @content_assets
        .ordered
        .by_content_types(params[:types])
        .by_filename(params[:query])
        .page(params[:page] || 1).per(params[:per_page] || Locomotive.config.ui[:per_page])
      respond_with(@content_assets)
    end

    def create
      authorize Locomotive::ContentAsset
      @content_asset = current_site.content_assets.create(params[:content_asset])
      respond_with @content_asset
    end

    def destroy
      authorize @content_asset
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
