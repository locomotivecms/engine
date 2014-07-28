module Locomotive
  module Api
    class TranslationsController < BaseController

      before_filter :load_translation,  only: [:show, :update, :destroy]
      before_filter :load_translations, only: [:index]

      def index
        respond_with(@translations)
      end

      def show
        ApplicationPolicy.new(self.current_locomotive_account, self.current_site, :translation).show?
        respond_with @translation
      end

      def create
        ApplicationPolicy.new(self.current_locomotive_account, self.current_site, :translation).create?
        @translation = Locomotive::Translation.new(params[:translation])
        @translation.from_presenter(params[:translation])
        @translation.save
        respond_with @translation, location: main_app.locomotive_api_translation_path(@translation)
      end

      def update
        ApplicationPolicy.new(self.current_locomotive_account, self.current_site, :translation).update?
        @translation.update_attributes(params[:translation])
        respond_with @translation, location: main_app.locomotive_api_translation_path(@translation)
      end

      def destroy
        ApplicationPolicy.new(self.current_locomotive_account, self.current_site, :translation).destroy?
        @translation.destroy
        respond_with @translation
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
