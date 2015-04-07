module Locomotive
  module API
    module Resources

      class SnippetResource < Grape::API

        resource :snippets do

          entity_klass = Entities::SnippetEntity

          before do
            setup_resource_methods_for(:snippets)
            authenticate_locomotive_account!
          end

          desc 'Index of snippets'
          get :index do
            authorize Snippet, :index?

            present snippets, with: entity_klass
          end

          desc 'Show a snippet'
          params do
            requires :id, type: String, desc: 'Snippet ID'
          end
          route_param :id do
            get do
              authorize snippet, :show?

              present snippet, with: entity_klass
            end
          end

          desc 'Create a snippet'
          params do
            requires :snippet, type: Hash do
              requires :name
              requires :slug
              requires :template
            end
          end
          post do
            authorize Snippet, :create?

            form = form_klass.new(snippet_params)
            persist_from_form(form)

            present snippet, with: entity_klass
          end

          desc "Update a Snippet"
          params do
            requires :id, type: String, desc: 'Snippet ID'
            requires :snippet, type: Hash do
              optional :name
              optional :slug
              optional :template
            end
          end
          put ':id' do
            authorize snippet, :update?

            form = form_klass.new(snippet_params)
            persist_from_form(form)

            present snippet, with: entity_klass
          end

          desc "Delete a snippet"
          params do
            requires :id, type: String, desc: 'Snippet ID'
          end
          delete ':id' do
            authorize snippet, :destroy?

            snippet.destroy

            present snippet, with: entity_klass
          end

        end

      end

    end
  end
end
