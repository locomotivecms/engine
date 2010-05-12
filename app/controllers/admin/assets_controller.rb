module Admin
  class AssetsController < BaseController
    
    sections 'assets'  
    
    before_filter :set_collections_and_current_collection
    
    def new
      @asset = @collection.assets.build
    end

    def edit
      @asset = @collection.assets.find(params[:id])
    end

    def create
      @asset = @collection.assets.build(params[:asset])

      if @asset.save
        flash_success!
        redirect_to edit_admin_asset_collection_url(@collection)
      else
        flash_error!
        render :action => 'new'
      end
    end

    def update
      @asset = @collection.assets.find(params[:id])

      if @asset.update_attributes(params[:asset])
        flash_success!
        redirect_to edit_admin_asset_collection_url(@collection)
      else
        flash_error!
        render :action => 'edit'
      end
    end
  
    protected 
  
    def set_collections_and_current_collection
      @collections = current_site.asset_collections
      @collection = @collections.find(params[:collection_id])
    end
    
  end
end
