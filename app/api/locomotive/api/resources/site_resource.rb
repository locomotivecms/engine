module Locomotive
  module API
    module Resources

      class SiteResource < Grape::API

        # This API does not use the persistence helper because it is quite different
        # from the other APIs.  Any changes to the persistence layer will need to
        # be manually applied to this API.  N.B.

        helpers do

          def service
            @service ||= Locomotive::SiteService.new(current_account)
          end

        end

        resource :sites do
          entity_klass = Entities::SiteEntity

          before do
            authenticate_locomotive_account!
          end

          helpers do
            def load_site
              policy_scope(Locomotive::Site).find(params[:id]).tap do |site|
                @current_site = site
              end
            end
          end

          desc 'Index of sites'
          get '/' do
            sites = policy_scope(Locomotive::Site)
            authorize(sites, :index?)

            present sites, with: entity_klass
          end

          desc 'Show a site'
          params do
            requires :id, type: String, desc: 'Site ID'
          end
          route_param :id do
            get do
              site = load_site
              authorize(site, :show?)

              present site, with: entity_klass
            end
          end

          desc 'Create a site'
          params do
            requires :site, type: Hash do
              requires :name
              optional :handle
              optional :seo_title
              optional :meta_keywords
              optional :meta_description
              optional :robots_txt
              optional :locales, type: Array
              optional :domains, type: Array
              optional :timezone
              optional :picture
              optional :cache_enabled
              optional :private_access
              optional :password
              optional :metafields_schema
              optional :metafields
              optional :metafields_ui
            end
          end
          post do
            authorize Site, :create?

            site_form = Forms::SiteForm.new(permitted_params_from_policy(Locomotive::Site, :site, [:picture]))
            site = service.create!(site_form.serializable_hash)

            present site, with: entity_klass
          end

          desc 'Update a site'
          params do
            requires :id, type: String, desc: 'Site ID'
            requires :site, type: Hash do
              optional :name
              optional :handle
              optional :seo_title
              optional :meta_keywords
              optional :meta_description
              optional :robots_txt
              optional :locales, type: Array
              optional :domains, type: Array
              optional :timezone
              optional :picture
              optional :cache_enabled
              optional :private_access
              optional :password
              optional :metafields_schema
              optional :metafields
            end
          end
          put ':id' do
            site = load_site
            authorize site, :update?

            site_form = Forms::SiteForm.new(permitted_params_from_policy(site, :site, [:picture]))
            site.assign_attributes(site_form.serializable_hash)
            site.save!

            present site, with: entity_klass
          end

          desc 'Delete a site'
          params do
            requires :id, type: String, desc: 'Site ID'
          end
          delete ':id' do
            site = load_site

            authorize site, :destroy?

            site.destroy

            present site, with: entity_klass
          end

        end

      end

    end
  end
end
