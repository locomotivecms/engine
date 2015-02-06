module Locomotive
  class TranslationAPI < Grape::API

    helpers do
      def translation_params
        permitted_params[:translation].merge(site: current_site)
      end
    end

    resource :translations do

      entity_class = Locomotive::TranslationEntity

      before do
        authenticate_locomotive_account!
      end

      desc 'Returns list of translations'
      get :index do
        translations = current_site.translations
        authorize translations, :index?

        present translations, with: entity_class
      end

      desc "Return a translation"
      params do
        requires :id, type: String, desc: 'Translation ID'
      end
      route_param :id do
        get do
          translation = current_site.translations.where(id: params[:id])
          authorize translation, :show?

          present translation, with: entity_class
        end
      end

      desc "Create a translation"
      params do
        requires :translation, type: Hash do
          requires :key, type: String
          requires :values, type: Hash
        end
      end
      post do
        authorize Translation, :create?
        translation = TranslationForm.new(translation_params)
        translation.save
      end

      desc "Edit a translation"
      params do
        requires :translation, type: Hash do
          requires :key, type: String
          requires :values, type: Hash
        end
      end
      post do
        authorize Translation, :edit?
        translation = TranslationForm.new(translation_params)
        translation.save
      end
    end

  end
end
