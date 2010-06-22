module Admin
  class AssetCollectionsController < BaseController
    
    sections 'assets'  
    
    before_filter :set_collections
  
    def index
      if not @collections.empty?
        redirect_to(edit_admin_asset_collection_url(@collections.first)) and return
      end
    end
  
    def show
      @collection = current_site.asset_collections.find(params[:id])
      render :action => 'edit'
    end

    def new
      @collection = current_site.asset_collections.build
    end

    def edit
      @collection = current_site.asset_collections.find(params[:id])
    end

    def create
      @collection = current_site.asset_collections.build(params[:asset_collection])

      if @collection.save
        flash_success!
        redirect_to edit_admin_asset_collection_url(@collection)
      else
        flash_error!
        render :action => 'new'
      end
    end

    def update
      @collection = current_site.asset_collections.find(params[:id])

      if @collection.update_attributes(params[:asset_collection])
        flash_success!
        redirect_to edit_admin_asset_collection_url(@collection)
      else
        flash_error!
        render :action => 'edit'
      end
    end

    def destroy
      @collection = current_site.asset_collections.find(params[:id])
      @collection.destroy

      flash_success!

      redirect_to admin_asset_collections_url
    end
  
    protected 
  
    def set_collections
      @collections = current_site.asset_collections.order_by([[:name, :asc]])
    end
  end
end
