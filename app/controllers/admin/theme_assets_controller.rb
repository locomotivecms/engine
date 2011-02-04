module Admin
  class ThemeAssetsController < BaseController

    include ActionView::Helpers::SanitizeHelper
    extend ActionView::Helpers::SanitizeHelper::ClassMethods
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::NumberHelper

    sections 'settings', 'theme_assets'

    respond_to :json, :only => [:create, :update]

    before_filter :sanitize_params, :only => [:create, :update]

    def index
      @assets = ThemeAsset.all_grouped_by_folder(current_site, params[:all])
      @js_and_css_assets = (@assets[:javascripts] || []) + (@assets[:stylesheets] || [])

      if request.xhr?
        @images = @assets[:images] || []
        render :action => 'images', :layout => false and return
      else
        @snippets = current_site.snippets.order_by([[:name, :asc]]).all.to_a
      end
    end

    def edit
      resource.performing_plain_text = true if resource.stylesheet_or_javascript?
      edit!
    end

    def create
      create! do |success, failure|
        success.json do
          render :json => {
            :status       => 'success',
            :url          => @theme_asset.source.url,
            :local_path   => @theme_asset.local_path(true),
            :size         => number_to_human_size(@theme_asset.size),
            :date         => l(@theme_asset.updated_at, :format => :short)
          }
        end
        failure.json { render :json => { :status => 'error' } }
      end
    end

    protected

    def sanitize_params
      params[:theme_asset] = { :source => params[:file] } if params[:file]

      performing_plain_text = params[:theme_asset][:performing_plain_text]
      params[:theme_asset].delete(:content_type) if performing_plain_text.blank? || performing_plain_text == 'false'
    end

  end

end
