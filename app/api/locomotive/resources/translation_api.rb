module Locomotive
  module Resources
    class TranslationAPI < Grape::API

      resource :translations do

        entity_class = Locomotive::TranslationEntity

        before do
          setup_methods_for(Translation, use_form_object: true)
          authenticate_locomotive_account!
        end

        desc 'Index of translations'
        get :index do
          auth :index?

          present translations, with: entity_class
        end


        desc "New translation"
        get :new do
          auth :new?
          translation = translations.build

          present translation, with: entity_class
        end


        desc "Show a translation"
        params do
          requires :id, type: String, desc: 'Translation ID'
        end
        route_param :id do
          get do
            auth :show?

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
          auth :create?

          form = translation_form.new(translation_params)
          form.site = current_site
          form.save

          present form, with: entity_class
        end


        desc "Edit a translation"
        params do
          requires :id, type: String, desc: 'Translation ID'
        end
        get ':id/edit' do
          object_auth :edit?

          present translation, with: entity_class
        end


        desc "Update a translation"
        params do
          requires :id, type: String, desc: 'Translation ID'
          requires :translation, type: Hash do
            optional :key, type: String
            optional :values, type: Hash
          end
        end
        put ':id' do
          object_auth :update?
          form = translation_form.existing(translation)

          form.update(translation_params)

          form.save

          present form, with: entity_class
        end


        desc "Destroy a translation"
        params do
          requires :id, type: String, desc: 'Translation ID'
        end
        delete ':id' do
          object_auth :destroy?

          translation.destroy

          present translation, with: entity_class
        end

      end

    end
  end
end
