module Locomotive
  module Resources
    class TranslationAPI < Grape::API

      resource :translations do

        entity_klass = Locomotive::TranslationEntity

        before do
          setup_resource_methods_for(:translations)
          authenticate_locomotive_account!
        end

        desc 'Index of translations'
        get :index do
          auth :index?

          present translations, with: entity_klass
        end


        desc "Show a translation"
        params do
          requires :id, type: String, desc: 'Translation ID'
        end
        route_param :id do
          get do
            auth :show?

            present translation, with: entity_klass
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

          form = form_klass.new(translation_params)
          persist_from_form(form)

          present translation, with: entity_klass
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
          form = form_klass.new(translation_params)
          persist_from_form(form)

          present translation, with: entity_klass
        end


        desc "Delete a translation"
        params do
          requires :id, type: String, desc: 'Translation ID'
        end
        delete ':id' do
          object_auth :destroy?

          translation.destroy

          present translation, with: entity_klass
        end

      end

    end
  end
end
