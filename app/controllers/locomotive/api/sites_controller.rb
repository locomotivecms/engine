module Locomotive
  module Api
    class SitesController < Api::BaseController

      skip_before_filter :require_site, :set_current_thread_variables

      before_filter :load_site, only: [:show, :update, :destroy]
      before_filter :load_sites, only: [:index]

      def index
        respond_with(@sites)
      end

      def show
        respond_with(@site)
      end

      def create
        authorize :site
        @site = Site.new
        @site.from_presenter(params[:site])
        @site.memberships.build account: self.current_locomotive_account, role: 'admin'
        @site.save
        respond_with(@site)
      end

      def update
        authorize :site
        @site.from_presenter(params[:site])
        @site.save
        respond_with @site
      end

      def destroy
        authorize :site
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
              response: SitePresenter.getters_to_hash,
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/sites/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            create: {
              description: %{Create a site},
              params: SitePresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' 'http://mysite.com/locomotive/api/sites.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            update: {
              description: %{Update a site},
              params: SitePresenter.setters_to_hash,
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

      private

      def load_site
        @site = current_site
      end

      def load_sites
        @sites = self.current_locomotive_account.to_scope(current_site, :sites)
      end

    end

  end
end
