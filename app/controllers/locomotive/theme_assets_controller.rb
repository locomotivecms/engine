module Locomotive
  class ThemeAssetsController < BaseController

    sections 'settings', 'theme_assets'

    respond_to :json, :only => [:index, :create, :update, :destroy]

    def index
      respond_to do |format|
        format.html {
          @assets             = ThemeAsset.all_grouped_by_folder(current_site)
          @js_and_css_assets  = (@assets[:javascripts] || []) + (@assets[:stylesheets] || [])
          @snippets           = current_site.snippets.order_by([[:name, :asc]]).all.to_a
          render
        }
        format.json {
          render :json => current_site.theme_assets.by_content_type(params[:content_type])
        }
      end
    end

    def new
      @theme_asset = current_site.theme_assets.build(params[:id])
      respond_with @theme_asset
    end

    def create
      @theme_asset = current_site.theme_assets.create(params[:theme_asset])
      respond_with @theme_asset, :location => edit_theme_asset_url(@theme_asset._id)
    end

    def edit
      @theme_asset = current_site.theme_assets.find(params[:id])
      @theme_asset.performing_plain_text = true if @theme_asset.stylesheet_or_javascript?
      respond_with @theme_asset
    end

    def update
      @theme_asset = current_site.theme_assets.find(params[:id])
      @theme_asset.update_attributes(params[:theme_asset])
      respond_with @theme_asset, :location => edit_theme_asset_url(@theme_asset._id)
    end

    def destroy
      @theme_asset = current_site.theme_assets.find(params[:id])
      @theme_asset.destroy
      respond_with @theme_asset
    end

  end

end
