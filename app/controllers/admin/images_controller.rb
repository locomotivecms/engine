module Admin
  class ImagesController < BaseController

    include ActionView::Helpers::SanitizeHelper
    include ActionView::Helpers::TextHelper

    defaults :collection_name => 'assets', :instance_name => 'asset'

    respond_to :json, :only => [:index, :create, :destroy]

    def index
      index! do |response|
        response.json do
          render :json => { :images => @assets.collect { |image| image_to_json(image) } }
        end
      end
    end

    def create
      params[:asset] = { :name => params[:name], :source => params[:file] } if params[:file]

      create! do |success, failure|
        success.json do
          render :json => image_to_json(@asset)
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
      @assets ||= begin_of_association_chain.assets
    end

    def begin_of_association_chain
      @asset_collection ||= AssetCollection.find_or_create_internal(current_site)
    end

    def image_to_json(image)
      {
        :status       => 'success',
        :name         => truncate(image.name, :length => 15),
        :url          => image.source.url,
        :vignette_url => image.vignette_url,
        :destroy_url  => admin_image_url(image, :json)
      }
    end

  end
end
