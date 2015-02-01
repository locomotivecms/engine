module Locomotive
  module Api
    class TranslationsController < Api::BaseController

      account_required & within_site

      before_filter :load_translation,  only: [:show, :update, :destroy]
      before_filter :load_translations, only: [:index]

      def index
        authorize Translation
        respond_with @translations
      end

      def show
        authorize @translation
        respond_with @translation
      end

      def create
        authorize Translation
        @translation = self.current_site.translations.build
        @translation.from_presenter(params[:translation]).save
        respond_with @translation, location: -> { main_app.locomotive_api_translation_url(@translation) }
      end

      def update
        authorize @translation
        @translation.from_presenter(params[:translation]).save
        respond_with @translation, location: main_app.locomotive_api_translation_url(@translation)
      end

      def destroy
        authorize @translation
        @translation.destroy
        respond_with @translation, location: main_app.locomotive_api_translations_url
      end

      private

      def load_translation
        @translation = self.current_site.translations.find params[:id]
      end

      def load_translations
        @translations = self.current_site.translations
      end

    end
  end
end
