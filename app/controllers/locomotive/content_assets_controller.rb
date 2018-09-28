module Locomotive
  class ContentAssetsController < BaseController

    account_required & within_site

    respond_to :json, only: [:index, :create, :bulk_create]

    before_action :load_content_assets, only: :index
    before_action :load_content_asset,  only: [:edit, :update, :destroy]

    def index
      authorize Locomotive::ContentAsset
      respond_with(@content_assets) do |format|
        format.html { render_index }
      end
    end

    def create
      authorize Locomotive::ContentAsset
      @content_asset = current_site.content_assets.create(content_asset_params)
      respond_with @content_asset, location: content_assets_path
    end

    def bulk_create
      @content_assets = service.bulk_create(content_assets_params)
      respond_with @content_assets, location: content_assets_path
    end

    def edit
      authorize @content_asset
      respond_with(@content_asset) do |format|
        format.html { render_edit }
      end
    end

    def destroy
      authorize @content_asset
      service.destroy(@content_asset)
      respond_with(@content_asset) do |format|
        format.html do
          if request.xhr?
            load_content_assets
            render_index
          else
            redirect_to content_assets_path
          end
        end
      end
    end

    private

    def load_content_assets
      @content_assets = service.list(params.slice(:types, :query, :page, :per_page))
    end

    def load_content_asset
      @content_asset = self.current_site.content_assets.find(params[:id])
    end

    def render_index
      render request.xhr? ? 'index_in_drawer' : 'index', layout: !request.xhr?
    end

    def render_edit
      render request.xhr? ? 'edit_in_drawer' : 'edit', layout: !request.xhr?
    end

    def service
      @service ||= Locomotive::ContentAssetService.new(current_site, current_locomotive_account)
    end

    def content_asset_params
      params.require(:content_asset).permit(:source)
    end

    def content_assets_params
      params.require(:content_assets).map { |p| p.permit(:source) }
    end

  end
end
