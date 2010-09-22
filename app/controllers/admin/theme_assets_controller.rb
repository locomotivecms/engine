module Admin
  class ThemeAssetsController < BaseController

    include ActionView::Helpers::SanitizeHelper
    extend ActionView::Helpers::SanitizeHelper::ClassMethods
    include ActionView::Helpers::TextHelper

    sections 'settings', 'theme_assets'

    respond_to :json, :only => [:create, :update]

    def index
      assets = current_site.theme_assets.all.to_a
      @non_image_assets = assets.find_all { |a| a.stylesheet? || a.javascript? }
      @image_assets = assets.find_all { |a| a.image? }
      @flash_assets = assets.find_all { |a| a.movie? }

      if request.xhr?
        render :action => 'images', :layout => false and return
      else
        @snippets = current_site.snippets.order_by([[:name, :asc]]).all.to_a
      end
    end

    def create
      params[:theme_asset] = { :source => params[:file] } if params[:file]

      create! do |success, failure|
        success.json do
          render :json => {
            :status       => 'success',
            :name         => truncate(@theme_asset.slug, :length => 22),
            :slug         => @theme_asset.slug,
            :url          => @theme_asset.source.url,
            :vignette_url => @theme_asset.vignette_url,
            :shortcut_url => @theme_asset.shortcut_url
          }
        end
        failure.json { render :json => { :status => 'error' } }
      end
    end

  end

end
