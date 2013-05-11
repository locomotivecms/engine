module Locomotive
  module Api
    class ContentTypesController < BaseController

      load_and_authorize_resource class: Locomotive::ContentType, through: :current_site

      def index
        @content_types = @content_types.order_by(:name.asc)
        respond_with(@content_types)
      end

      def show
        respond_with @content_type
      end

      def create
        @content_type.from_presenter(params[:content_type])
        @content_type.save
        respond_with @content_type, location: main_app.locomotive_api_content_types_url
      end

      def update
        @content_type.from_presenter(params[:content_type])
        @content_type.save
        respond_with @content_type, location: main_app.locomotive_api_content_types_url
      end

      def destroy
        @content_type.destroy
        respond_with @content_type
      end

      protected

      def self.description
        {
          overall: %{Manage the content types},
          actions: {
            index: {
              description: %{Return all the content types ordered by the depth and position},
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/content_types.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            show: {
              description: %{Return the attributes of a content type},
              response: Locomotive::ContentTypePresenter.getters_to_hash,
              example: {
                command: %{curl 'http://mysite.com/locomotive/api/content_types/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            create: {
              description: %{Create a content type},
              params: Locomotive::ContentTypePresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' 'http://mysite.com/locomotive/api/content_types.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            update: {
              description: %{Update a content type},
              params: Locomotive::ContentTypePresenter.setters_to_hash,
              example: {
                command: %{curl -d '...' -X UPDATE 'http://mysite.com/locomotive/api/content_types/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            },
            destroy: {
              description: %{Delete a content type},
              example: {
                command: %{curl -X DELETE 'http://mysite.com/locomotive/api/content_types/4244af4ef0000002.json?auth_token=dtsjkqs1TJrWiSiJt2gg'},
                response: %(TODO)
              }
            }
          }
        }
      end

    end
  end
end