module Admin
  class AssetCollectionsController < BaseController

    sections 'assets'

    before_filter :set_collections

    def index
      if not @asset_collections.empty?
        redirect_to(edit_admin_asset_collection_url(@asset_collections.first)) and return
      end
    end

    def show
      @asset_collection = current_site.asset_collections.find(params[:id])
      render :action => 'edit'
    end

    protected

    def set_collections
      @asset_collections = current_site.asset_collections.not_internal.order_by([[:name, :asc]])
    end
  end
end
