module Admin
  class AssetsController < BaseController

    sections 'assets'

    before_filter :set_collections_and_current_collection

    respond_to :json, :only => :update

    def create
      create! { edit_admin_asset_collection_url(@asset_collection) }
    end

    def update
      update! { edit_admin_asset_collection_url(@asset_collection) }
    end

    protected

    def begin_of_association_chain
      @asset_collection
    end

    def set_collections_and_current_collection
      @asset_collections = current_site.asset_collections.not_internal.order_by([[:name, :asc]])
      @asset_collection = current_site.asset_collections.find(params[:collection_id])
    end

  end
end
