module Locomotive
  class ThemeAssetsController < BaseController

    sections 'settings', 'theme_assets'

    respond_to :json, only: [:index, :create, :update, :destroy]

    before_filter :load_theme_asset, only: [:edit, :update, :destroy]

    def index
      authorize ThemeAsset
      respond_to do |format|
        format.html {
          @assets             = ThemeAsset.all_grouped_by_folder(current_site)
          @js_and_css_assets  = (@assets[:javascripts] || []) + (@assets[:stylesheets] || [])
          @snippets           = current_site.snippets.order_by(:name.asc).all.to_a
          render
        }
        format.json {
          render json: current_site.theme_assets.by_content_type(params[:content_type])
        }
      end
    end

    def new
      authorize ThemeAsset
      @theme_asset = current_site.theme_assets.build(params[:id])
      respond_with @theme_asset
    end

    def create
      authorize ThemeAsset
      @theme_asset = current_site.theme_assets.create(params[:theme_asset])
      respond_with @theme_asset, location: edit_theme_asset_path(@theme_asset._id)
    end

    def edit
      authorize @theme_asset
      @theme_asset.performing_plain_text = true if @theme_asset.stylesheet_or_javascript?
      respond_with @theme_asset
    end

    def update
      authorize @theme_asset
      @theme_asset.update_attributes(params[:theme_asset])
      respond_with @theme_asset, location: edit_theme_asset_path(@theme_asset._id)
    end

    def destroy
      authorize @theme_asset
      @theme_asset.destroy
      respond_with @theme_asset
    end

    private

    def load_theme_asset
      @theme_asset = current_site.theme_assets.find(params[:id])
    end
  end
end
