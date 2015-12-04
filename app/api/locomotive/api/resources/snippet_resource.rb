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
          get '/' do
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

          desc 'Update a Snippet (or create one)'
          params do
            requires :id, type: String, desc: 'Snippet ID or Slug'
            requires :snippet, type: Hash do
              optional :name
              optional :slug
              optional :template
            end
          end
          put ':id' do
            if @snippet = current_site.snippets.by_id_or_slug(params[:id]).first
              authorize @snippet, :update?
            else
              authorize Snippet, :create?
              @snippet = current_site.snippets.build
            end

            form = form_klass.new(snippet_params)
            persist_from_form(form)

            present snippet, with: entity_klass
          end

          desc "Delete a snippet"
          params do
            requires :id, type: String, desc: 'Snippet ID or SLUG'
          end
          delete ':id' do
            @snippet = current_site.snippets.by_id_or_slug(params[:id]).first

            raise ::Mongoid::Errors::DocumentNotFound.new(current_site.snippets, params) if snippet.nil?

            object_auth :destroy?

            snippet.destroy

            present snippet, with: entity_klass
          end

          desc 'Delete all snippets'
          delete '/' do
            auth :destroy_all?

            number = current_site.snippets.count

            current_site.snippets.destroy_all

            present({ deletions: number })
          end

        end

      end

    end
  end
end
