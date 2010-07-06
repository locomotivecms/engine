module Admin
  class ThemeAssetsController < BaseController

    include ActionView::Helpers::TextHelper

    sections 'settings', 'theme_assets'
   
    def index
      assets = current_site.theme_assets.all
      @non_image_assets = assets.find_all { |a| a.stylesheet? || a.javascript? }
      @image_assets = assets.find_all { |a| a.image? }
      @flash_assets = assets.find_all { |a| a.movie? }
      
      if request.xhr?
        render :action => 'images', :layout => false
      end
    end
    
    def new
      @asset = current_site.theme_assets.build
    end
    
    def edit
      @asset = current_site.theme_assets.find(params[:id])
    end
    
    def create
      params[:theme_asset] = { :source => params[:file] } if params[:file]
      
      @asset = current_site.theme_assets.build(params[:theme_asset])
      
      respond_to do |format|
        if @asset.save
          format.html do
            flash_success!
            redirect_to edit_admin_theme_asset_url(@asset)
          end
          format.json do
            render :json => { 
              :status => 'success', 
              :name => truncate(@asset.slug, :length => 22),
              :url => @asset.source.url,
              :vignette_url => @asset.vignette_url
            }
          end
        else
          format.html do
            flash_error!
            render :action => 'new'
          end
          format.json do
            render :json => { :status => 'error' }
          end
        end
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