module Admin
  class ThemeAssetsController < BaseController

    sections 'settings', 'theme_assets'
   
    def index
      assets = current_site.theme_assets.all
      @non_image_assets = assets.find_all { |a| a.stylesheet? || a.javascript? }
      @image_assets = assets.find_all { |a| a.image? }
    end
    
    def new
      @asset = current_site.theme_assets.build
    end
    
    def edit
      @asset = current_site.theme_assets.find(params[:id])
    end
    
    def create
      @asset = current_site.theme_assets.build(params[:theme_asset])

      if @asset.save
        flash_success!
        redirect_to edit_admin_theme_asset_url(@asset)
      else
        flash_error!
        render :action => 'new'
      end
    end
    
    def update
      @asset = current_site.theme_assets.find(params[:id])

      if @asset.update_attributes(params[:theme_asset])
        flash_success!
        redirect_to edit_admin_theme_asset_url(@asset)
      else
        flash_error!
        render :action => 'edit'
      end
    end
    
    def destroy
      @asset = current_site.theme_assets.find(params[:id])
      @asset.destroy

      flash_success!
      redirect_to admin_theme_assets_url
    end
    
  end
  
end