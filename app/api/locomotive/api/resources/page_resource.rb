module Locomotive
  module API
    module Resources

      class PageResource < Grape::API

        resource :pages do
          entity_klass = Entities::PageEntity

          before do
            setup_resource_methods_for(:pages)
            authenticate_locomotive_account!
          end

          desc 'Index of pages'
          get :index do
            authorize(pages, :index?)

            present pages, with: entity_klass
          end


          desc "Show a page"
          params do
            requires :id, type: String, desc: 'Page ID'
          end
          route_param :id do
            get do
              authorize(page, :show?)

              present page, with: entity_klass
            end
          end


          desc 'Create a page'
          params do
            requires :page, type: Hash do
              optional :title
              optional :slug
              optional :parent_id
              optional :parent_fullpath
              optional :position, type: Integer
              optional :handle
              optional :response_type
              optional :cache_strategy
              optional :redirect, type: Boolean
              optional :redirect_url
              optional :redirect_type
              optional :listed, type: Boolean
              optional :published, type: Boolean
              optional :templatized, type: Boolean
              optional :is_layout, type: Boolean
              optional :allow_layout, type: Boolean
              optional :templatized_from_parent, type: Boolean
              optional :fullpath
              optional :localized_fullpaths, type: Hash
              optional :editable_elements, type: Array
              optional :depth, type: Integer
              optional :template_changed, type: Boolean
              optional :translated_in, type: Array
              optional :target_klass_slug
              # End Aliases
              optional :seo_title
              optional :meta_keywords
              optional :meta_description
            end
          end
          post do
            authorize Page, :create?
            form = form_klass.new(page_params)
            persist_from_form(form)

            present page, with: entity_klass
          end

          desc 'Update a page'
          params do
            requires :id, type: String, desc: 'Page ID'
            requires :page, type: Hash do
              optional :title
              optional :slug
              optional :parent_id
              optional :parent_fullpath
              optional :position, type: Integer
              optional :handle
              optional :response_type
              optional :cache_strategy
              optional :redirect, type: Boolean
              optional :redirect_url
              optional :redirect_type
              optional :listed, type: Boolean
              optional :published, type: Boolean
              optional :templatized, type: Boolean
              optional :is_layout, type: Boolean
              optional :allow_layout, type: Boolean
              optional :templatized_from_parent, type: Boolean
              optional :fullpath
              optional :localized_fullpaths, type: Hash
              optional :editable_elements, type: Array
              optional :depth, type: Integer
              optional :template_changed, type: Boolean
              optional :translated_in, type: Array
              # Aliases for target_klass_slug
              optional :target_klass_slug
              optional :target_klass_name
              optional :target_entry_name
              # End Aliases
              optional :seo_title
              optional :meta_keywords
              optional :meta_description
            end
          end
          put ':id' do
            object_auth :update?
            form = form_klass.new(page_params)
            persist_from_form(form)

            present page, with: entity_klass
          end

          desc "Delete a page"
          params do
            requires :id, type: String, desc: 'Page ID'
          end
          delete ':id' do
            authorize page, :destroy?

            page.destroy

            present page, with: entity_klass
          end

        end

      end

    end
  end
end
