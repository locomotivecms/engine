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
          get '/' do
            authorize(pages, :index?)

            present pages, with: entity_klass, site: current_site
          end


          desc "Show a page"
          params do
            requires :id, type: String, desc: 'Page ID'
          end
          route_param :id do
            get do
              authorize(page, :show?)

              present page, with: entity_klass, site: current_site
            end
          end

          desc 'Create a page'
          params do
            requires :page, type: Hash do
              requires :title
              requires :slug
              requires :parent
              optional :position, type: Integer
              optional :handle
              optional :response_type
              optional :redirect_url
              optional :redirect_type
              optional :listed, type: Boolean
              optional :published, type: Boolean
              optional :templatized, type: Boolean
              optional :content_type, type: String
              optional :is_layout, type: Boolean
              optional :allow_layout, type: Boolean
              optional :editable_elements, type: Array
              optional :seo_title
              optional :meta_keywords
              optional :meta_description
            end
          end
          post do
            authorize Page, :create?
            form = form_klass.new(current_site, page_params)
            persist_from_form(form)

            present page, with: entity_klass, site: current_site
          end

          desc 'Update a page'
          params do
            requires :id, type: String, desc: 'Page ID'
            requires :page, type: Hash do
              optional :title
              optional :slug
              optional :parent
              optional :position, type: Integer
              optional :handle
              optional :response_type
              optional :redirect_url
              optional :redirect_type
              optional :listed, type: Boolean
              optional :published, type: Boolean
              optional :content_type, type: Boolean
              optional :is_layout, type: Boolean
              optional :allow_layout, type: Boolean
              optional :template
              optional :editable_elements, type: Array
              optional :seo_title
              optional :meta_keywords
              optional :meta_description
            end
          end
          put ':id' do
            object_auth :update?
            form = form_klass.new(current_site, page_params, page)
            persist_from_form(form)

            present page, with: entity_klass, site: current_site
          end

          desc "Delete a page"
          params do
            requires :id, type: String, desc: 'Page ID'
          end
          delete ':id' do
            authorize page, :destroy?

            page.destroy

            present page, with: entity_klass, site: current_site
          end

        end

      end

    end
  end
end
