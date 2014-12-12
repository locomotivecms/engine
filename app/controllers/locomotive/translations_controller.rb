module Locomotive
  class TranslationsController < BaseController

    respond_to :json, only: [:create, :update]

    before_filter :load_translation, only: [:edit, :update, :destroy]

    def index
      authorize ThemeAsset
      @translations = current_site.translations.ordered.page(params[:page]).per(Locomotive.config.ui[:per_page])
      respond_with @translations
    end

    def new
      authorize ThemeAsset
      @translation = current_site.translations.build
      respond_with @translation
    end

    def create
      authorize ThemeAsset
      @translation = current_site.translations.create(params[:translation])
      respond_with @translation, location: translations_path
    end

    def edit
      authorize @translation
      respond_with @translation
    end

    def update
      authorize @translation
      @translation.update_attributes(params[:translation])
      respond_with @translation, location: translations_path
    end

    def destroy
      authorize @translation
      @translation.destroy
      respond_with @translation, location: translations_path
    end

    private

    def load_translation
      @translation = current_site.translations.find(params[:id])
    end
  end
end
