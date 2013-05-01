module Locomotive
  class TranslationsController < BaseController

    sections :settings, :translations

    respond_to :json, only: [:create, :update]

    def index
      @translations = current_site.translations.ordered.page(params[:page]).per(Locomotive.config.ui[:per_page])
      respond_with @translations
    end

    def new
      @translation = current_site.translations.build
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

    def destroy
      @translation = current_site.translations.find(params[:id])
      @translation.destroy
      respond_with @translation, location: translations_path
    end
  end
end