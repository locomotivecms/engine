module Locomotive
  class ContentAssetsController < BaseController

    respond_to :json, only: [:create, :bulk_create]

    def index
      self.list_assets

      respond_with(@content_asset) do |format|
        format.html { render_index }
      end
    end

    def create
      @content_asset = current_site.content_assets.create(params[:content_asset])
      respond_with @content_asset, location: content_assets_path
    end

    def bulk_create
      @content_assets = service.bulk_create(params[:content_assets])
      respond_with @content_assets, location: content_assets_path
    end

    def destroy
      @content_asset = current_site.content_assets.find(params[:id])
      @content_asset.destroy

      self.list_assets

      respond_with(@content_asset) do |format|
        format.html { render_index }
      end
    end

    protected

    def service
      @service ||= Locomotive::ContentAssetsService.new(current_site)
    end

    def list_assets
      @content_assets = service.list(params.slice(:types, :query, :page, :per_page))
    end

    def render_index
      render request.xhr? ? 'index_in_drawer' : 'index', layout: !request.xhr?
    end

  end
end