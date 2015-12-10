module Locomotive
  module API
    module Resources

      class TranslationResource < Grape::API

        resource :translations do

          entity_klass = Entities::TranslationEntity

          before do
            setup_resource_methods_for(:translations)
            authenticate_locomotive_account!
          end

          desc 'Index of translations'
          get '/' do
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


          desc "Update a Translation (or create one)"
          params do
            requires :id, type: String, desc: 'Translation ID or Key'
            requires :translation, type: Hash do
              optional :key, type: String
              optional :values, type: Hash
            end
          end
          put ':id' do
            if @translation = current_site.translations.by_id_or_key(params[:id]).first
              authorize @translation, :update?
            else
              authorize Translation, :create?
              @translation = current_site.translations.build
            end

            form = form_klass.new(translation_params)
            persist_from_form(form)

            present translation, with: entity_klass
          end

          desc "Delete a translation"
          params do
            requires :id, type: String, desc: 'Translation ID or KEY'
          end
          delete ':id' do
            @translation = current_site.translations.by_id_or_key(params[:id]).first

            raise ::Mongoid::Errors::DocumentNotFound.new(current_site.translations, params) if translation.nil?

            object_auth :destroy?

            translation.destroy

            present translation, with: entity_klass
          end

          desc 'Delete all translations'
          delete '/' do
            auth :destroy_all?

            number = current_site.translations.count

            current_site.translations.destroy_all

            present({ deletions: number })
          end

        end

      end

    end
  end
end
