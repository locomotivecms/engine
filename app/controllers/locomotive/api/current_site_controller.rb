module Locomotive
  module Api
    class CurrentSiteController < Api::BaseController

      before_filter :load_current_site

      def show
        respond_with(@site)
      end

      def update
        ApplicationPolicy.new(self.current_locomotive_account, self.current_site, :site).update?
        @site.from_presenter(params[:site])
        @site.save
      	respond_with(@site)
      end

      def destroy
        ApplicationPolicy.new(self.current_locomotive_account, self.current_site, :site).destroy?
        @site.destroy
        respond_with(@site)
      end

      def self.description
        {
          overall: %{Manage the current site related to the domain name used to make the API call},
          actions: {
            show: {
              description: %{Return the attributes of the current site},
              response: SitePresenter.getters_to_hash,
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/tokens.json'},
                response: %(TODO)
              }
            },
            update: {
              description: %{Update the current site},
              params: SitePresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' -X UPDATE 'http://mysite.com/locomotive/api/current_site.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            destroy: {
              description: %{Delete the current site},
              example: {
                command: %{curl -X DELETE 'http://mysite.com/locomotive/api/current_site.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            }
          }
        }
      end

      private

      def load_current_site
        @site = current_site
      end

    end
  end
end
