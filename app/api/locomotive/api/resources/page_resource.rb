module Locomotive
  module API
    module Resources

      class PageResource < Grape::API

        resource :pages do
          entity_klass = Entities::PageEntity

          helpers do

            def url_builder
              Locomotive::Steam::Services.build_simple_instance(current_site).url_builder
            end

          end

          before do
            setup_resource_methods_for(:pages)
            authenticate_locomotive_account!
          end

          desc 'Index of pages'
          get '/' do
            authorize Page, :index?

            present pages, with: entity_klass, site: current_site, url_builder: url_builder
          end

          desc 'Only full path of pages'
          get '/fullpaths' do
            authorize Page, :index?

            present pages.only(:id, :fullpath, :handle), with: Locomotive::API::Entities::FullpathPageEntity
          end

          desc "Show a page"
          params do
            requires :id, type: String, desc: 'Page ID'
          end
          route_param :id do
            get do
              authorize(page, :show?)

              present page, with: entity_klass, site: current_site, url_builder: url_builder
            end
          end

          desc 'Create a page (in the default locale)'
          params do
            requires :page, type: Hash do
              requires :title
              requires :slug
              requires :parent
              optional :template
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
              optional :sections_content, type: String
              optional :sections_dropzone_content, type: String
              optional :cache_enabled
              optional :seo_title
              optional :meta_keywords
              optional :meta_description
              optional :display_settings
            end
          end
          post do
            authorize Page, :create?

            back_to_default_site_locale

            form = form_klass.new(current_site, page_params)

            persist_from_form(form)

            present page, with: entity_klass, site: current_site, url_builder: url_builder
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
              optional :content_type
              optional :is_layout, type: Boolean
              optional :allow_layout, type: Boolean
              optional :template
              optional :editable_elements, type: Array
              optional :sections_content, type: String
              optional :sections_dropzone_content, type: String
              optional :cache_enabled
              optional :seo_title
              optional :meta_keywords
              optional :meta_description
              optional :display_settings
            end
          end
          put ':id' do
            object_auth :update?
            form = form_klass.new(current_site, page_params, page)

            persist_from_form(form)

            present page, with: entity_klass, site: current_site, url_builder: url_builder
          end

          desc 'Delete a page'
          params do
            requires :id, type: String, desc: 'Page ID or PATH'
          end
          delete '*id' do
            page_id_or_fullpath = params[:id].split('.json').first
            @page = current_site.pages.by_id_or_fullpath(page_id_or_fullpath).first

            raise ::Mongoid::Errors::DocumentNotFound.new(current_site.pages, { id: page_id_or_fullpath }) if page.nil?

            object_auth :destroy?

            page.destroy

            present page, with: entity_klass, site: current_site, url_builder: url_builder
          end

        end

      end

    end
  end
end
