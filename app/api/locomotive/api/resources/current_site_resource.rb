module Locomotive
  module API
    class CurrentSiteResource < Grape::API

      resource :current_site do
        entity_klass = Locomotive::API::SiteEntity

        before do
          authenticate_locomotive_account!
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
            optional :timezone
          end
        end
        put do
          authorize current_site, :update?

          current_site_form = SiteForm.new(permitted_params[:site])
          current_site.assign_attributes(current_site_form.serializable_hash)
          current_site.save

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
