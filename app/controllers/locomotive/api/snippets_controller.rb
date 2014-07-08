module Locomotive
  module Api
    class SnippetsController < BaseController

      before_filter :load_resources, only: [:index]
      before_filter :load_resource,  only: [:show, :update, :destroy]

      def index
        @snippets = SnippetPolicy::Scope.new(self.current_locomotive_account).resolve
        @snippets = @snippets.order_by(:name.asc)

        respond_with(@snippets)
      end

      def show
        SnippetPolicy.new(self.current_locomotive_account, @snippet).show?

        respond_with @snippet
      end

      def create
        @snippet = Locomotive::Snippet.new(params[:snippet])
        SnippetPolicy.new(self.current_locomotive_account, @snippet).create?

        @snippet.from_presenter(params[:snippet])
        @snippet.site = current_site
        @snippet.save

        respond_with @snippet, location: main_app.locomotive_api_snippets_url
      end

      def update
        SnippetPolicy.new(self.current_locomotive_account, @snippet).update?

        @snippet.from_presenter(params[:snippet])
        @snippet.save

        respond_with @snippet, location: main_app.locomotive_api_snippets_url
      end

      def destroy
        SnippetPolicy.new(self.current_locomotive_account, @snippet).destroy?

        @snippet.destroy

        respond_with @snippet
      end

      protected

      def self.description
        {
          overall: %{Manage the snippets},
          actions: {
            index: {
              description: %{Return all the snippets ordered by the depth and position},
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/snippets.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            show: {
              description: %{Return the attributes of a snippet},
              response: Locomotive::SnippetPresenter.getters_to_hash,
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/snippets/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            create: {
              description: %{Create a snippet},
              params: Locomotive::SnippetPresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' 'http://mysite.com/locomotive/api/snippets.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            update: {
              description: %{Update a snippet},
              params: Locomotive::SnippetPresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' -X UPDATE 'http://mysite.com/locomotive/api/snippets/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            destroy: {
              description: %{Delete a snippet},
              example: {
                command: %{curl -X DELETE 'http://mysite.com/locomotive/api/snippets/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            }
          }
        }
      end

      private

      def load_resources
        @snippets = current_site.snippets
      end

      def load_resource
        @snippet = current_site.snippets.find params[:id]
      end

    end
  end
end
