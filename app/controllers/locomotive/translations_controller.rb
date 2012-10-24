module Locomotive
  class TranslationsController < BaseController
    sections :settings, :translations
    load_and_authorize_resource through: :current_site
    
    def index
    end
    
    def new
      respond_with @translation
    end
    
    def create
      @translation = current_site.translations.create(params[:translation])
      respond_with @translation, location: translations_path
    end
    
    def edit
      respond_with @translation
    end
    
    def update
      @translation = current_site.translations.find(params[:id])
      @translation.update_attributes(params[:translation])
      respond_with @translation, location: translations_path
    end
  end
end