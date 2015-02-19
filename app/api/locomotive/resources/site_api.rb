module Locomotive
  module Resources
    class SiteAPI < Grape::API

      resource :sites do
        entity_klass = Locomotive::SiteEntity

        helpers do
          def service
            @service ||= Locomotive::SiteService.new(current_account)
          end

        end

        before do
          authenticate_locomotive_account!
        end

        desc 'Index of sites'
        get :index do
          sites = policy_scope(Locomotive::Site)
          authorize(sites, :index?)

          present sites, with: entity_klass
        end

        desc "Show a site"
        params do
          requires :id, type: String, desc: 'Site ID'
        end
        route_param :id do
          get do
            site = policy_scope(Locomotive::Site).find(params[:id])
            authorize(site, :show?)
            
            present site, with: entity_klass
          end
        end

      end

    end
  end
end
