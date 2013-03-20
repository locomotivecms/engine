module Locomotive
  module Api
    class SitesController < Api::BaseController

      skip_before_filter :require_site, :set_current_thread_variables

      load_and_authorize_resource class: Locomotive::Site

      # We make an exception for the index action, we don't use the ability
      # object, we just return the sites owned by the current account.
      skip_load_and_authorize_resource only: :index

      def index
        @sites = self.current_locomotive_account.sites.all
        respond_with(@sites)
      end

      def show
        respond_with(@site)
      end

      def create
        @site.from_presenter(params[:site])
        @site.memberships.build account: self.current_locomotive_account, role: 'admin'
        @site.save
        respond_with(@site)
      end

      def update
        @site.from_presenter(params[:site])
        @site.save
        respond_with @site
      end

      def destroy
        @site.destroy
        respond_with(@site)
      end

      protected

      def self.description
        {
          overall: %{Manage the sites for which the logged in user is admin},
          actions: {
            index: {
              description: %{Return all the sites},
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/sites.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            show: {
              description: %{Return the attributes of a site},
              response: Locomotive::SitePresenter.getters_to_hash,
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/sites/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            create: {
              description: %{Create a site},
              params: Locomotive::SitePresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' 'http://mysite.com/locomotive/api/sites.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            update: {
              description: %{Update a site},
              params: Locomotive::SitePresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' -X UPDATE 'http://mysite.com/locomotive/api/sites/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            destroy: {
              description: %{Delete a site},
              example: {
                command: %{curl -X DELETE 'http://mysite.com/locomotive/api/sites/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            }
          }
        }
      end

    end

  end
end

