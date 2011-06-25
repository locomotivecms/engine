module Admin
  class AssetsController < BaseController

    include ActionView::Helpers::SanitizeHelper
    include ActionView::Helpers::TextHelper

    respond_to :json, :only => [:index, :create, :destroy]

    def index
      index! do |response|
        response.json do
          render :json => { :assets => @assets.collect { |asset| asset_to_json(asset) } }
        end
      end
    end

    def create
      @asset = current_site.assets.build(:name => params[:name], :source => params[:file])

      create! do |success, failure|
        success.json do
          render :json => asset_to_json(@asset)
        end
        failure.json do
          render :json => { :status => 'error' }
        end
      end
    rescue Exception => e
      render :json => { :status => 'error', :message => e.message }
    end

    protected

    def collection
      if params[:image]
        @assets ||= begin_of_association_chain.assets.only_image
      else
        @assets ||= begin_of_association_chain.assets
      end
    end

    def asset_to_json(asset)
      {
        :status       => 'success',
        :filename     => asset.source_filename,
        :short_name   => truncate(asset.name, :length => 15),
        :extname      => truncate(asset.extname, :length => 3),
        :content_type => asset.content_type,
        :url          => asset.source.url,
        :vignette_url => asset.vignette_url,
        :destroy_url  => admin_asset_url(asset, :json)
      }
    end

  end
end
