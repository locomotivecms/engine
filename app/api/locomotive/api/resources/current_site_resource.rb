module Locomotive
  module API
    module Resources

      class CurrentSiteResource < Grape::API

        resource :current_site do
          entity_klass = Entities::SiteEntity

          before do
            authenticate_locomotive_account!
            require_site!
          end

          helpers do

            def service
              @service ||= Locomotive::SiteService.new(current_account)
            end

          end

          desc 'Show current_site'
          get do
            authorize current_site, :show?

            present current_site, with: entity_klass
          end

          desc 'Update current site'
          params do
            requires :site, type: Hash do
              optional :name
              optional :handle
              optional :seo_title
              optional :meta_keywords
              optional :meta_description
              optional :robots_txt
              optional :locales, type: Array
              optional :domains, type: Array
              optional :url_redirections, type: Array
              optional :timezone
              optional :picture
              optional :metafields_schema
              optional :metafields
              optional :metafields_ui
              optional :asset_host
            end
          end
          put do
            authorize current_site, :update?

            current_site_form = Forms::SiteForm.new(permitted_params_from_policy(current_site, :site, [:picture], [:metafields_ui, :metafields_schema, :metafields]))
            service.update!(current_site, current_site_form.serializable_hash)

            present current_site, with: entity_klass
          end


          desc "Delete current site"
          delete do
            authorize current_site, :destroy?

            current_site.destroy

            present current_site, with: entity_klass
          end

        end
      end

    end

  end
end
