module Admin
  class ThemeAssetsController < BaseController
    require 'coffee-script'

    include ActionView::Helpers::SanitizeHelper
    extend ActionView::Helpers::SanitizeHelper::ClassMethods
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::NumberHelper

    sections 'settings', 'theme_assets'

    respond_to :json, :only => [:create, :update]

    before_filter :sanitize_params, :only => [:create, :update]

    before_filter :compile, :only => [:update]
    after_filter :store, :only => [:create, :update]

    def compile
      if @theme_asset.coffeescript?
        begin
          CoffeeScript.compile params[:theme_asset][:plain_text]
        rescue Exception => e
          flash[:error] = e.message
        end
      end
    end
    
    def store
      if @theme_asset.coffeescript?
        begin
          javascript = CoffeeScript.compile @theme_asset.source.read()
        rescue Exception => e
          javascript = "console.log('Error in #{@theme_asset.source.url}: #{e.message}');"
        end
        
        a = ThemeAsset.where(:source_filename=> @theme_asset.source_filename.gsub('.coffee', '.js')).first()
        if a
          a.update_attributes({:site => @current_site,
                               :plain_text_name => @theme_asset.source_filename.gsub('.coffee', '.js'),
                               :plain_text_type => "javascript",
                               :plain_text => javascript,
                               :folder => "javascripts",
                               :performing_plain_text => true})
        else
          ThemeAsset.create!({:site => @current_site,
                              :plain_text_name => @theme_asset.source_filename.gsub('.coffee', '.js'),
                              :plain_text_type => "javascript",
                              :plain_text => javascript,
                              :folder => "",
                              :performing_plain_text => true})
        end
      end
    end
    
    def index
      @assets = ThemeAsset.all_grouped_by_folder(current_site)
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
    end

  end

end
