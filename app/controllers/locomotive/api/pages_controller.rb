module Locomotive
  module Api
    class PagesController < BaseController

      before_filter :load_page, only: [:show, :update, :destroy]

      def index
        @pages = PagePolicy::Scope.new(self.current_locomotive_account, self.current_site).resolve
        @pages = @pages.order_by(:depth.asc, :position.asc)

        respond_with(@pages)
      end

      def show
        ApplicationPolicy.new(self.current_locomotive_account, @page).show?

        respond_with(@page)
      end

      def create
        @page = Page.new(params[:page])
        ApplicationPolicy.new(self.current_locomotive_account, @page).create?

        @page.from_presenter(params[:page])
        @page.save

        respond_with @page, location: main_app.locomotive_api_pages_url
      end

      def update
        ApplicationPolicy.new(self.current_locomotive_account, @page).update?
        @page.from_presenter(params[:page])
        @page.save
        respond_with @page, location: main_app.locomotive_api_pages_url
      end

      def destroy
        ApplicationPolicy.new(self.current_locomotive_account, @page).destroy?
        @page.destroy
        respond_with @page
      end

      protected

      def self.description
        {
          overall: %{Manage the pages},
          actions: {
            index: {
              description: %{Return all the pages ordered by the depth and position},
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/pages.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            show: {
              description: %{Return the attributes of a page},
              response: PagePresenter.getters_to_hash,
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/pages/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            create: {
              description: %{Create a page},
              params: PagePresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' 'http://mysite.com/locomotive/api/pages.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            update: {
              description: %{Update a page},
              params: PagePresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' -X UPDATE 'http://mysite.com/locomotive/api/pages/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            destroy: {
              description: %{Delete a page},
              example: {
                command: %{curl -X DELETE 'http://mysite.com/locomotive/api/pages/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            }
          }
        }
      end

      def load_page
        @page = current_site.pages.find params[:id]
      end

    end

  end
end
