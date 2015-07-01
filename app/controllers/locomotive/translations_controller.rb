module Locomotive
  class TranslationsController < BaseController

    account_required & within_site

    before_filter :load_translation, only: [:edit, :update]

    def index
      authorize ThemeAsset
      @translations = service.all(params.slice(:page, :per_page, :q, :filter_by))
      respond_with @translations
    end

    def edit
      authorize @translation
      respond_with @translation
    end

    def update
      authorize @translation
      service.update(@translation, translation_params[:values])
      respond_with @translation, location: translations_path(current_site, params[:_location])
    end

    private

    def load_translation
      @translation = current_site.translations.find(params[:id])
    end

    def translation_params
      params.require(:translation).permit(values: current_site.locales)
    end

    def service
      @service ||= Locomotive::TranslationService.new(current_site, current_locomotive_account)
    end

  end
end
