module Locomotive
  module Concerns
    module Site
      module Routes

        extend ActiveSupport::Concern
        include Concerns::Shared::JsonAttribute

        included do

          ## fields ##
          field :routes, type: Array, default: []

          ## behaviours ##
          json_attribute  :routes
        end

        private

        # Example:
        #
        # [
        #   {
        #     "route": "/blog/:year/:month",
        #     "page_handle": "posts"
        #   },
        #   {
        #     "route": "/archived-projects/:category",
        #     "page_handle": "projects"
        #   }
        # ]
        #
        def _routes_schema
          {
            id: 'http://www.locomotive.cms/schemas/page/routes.json',
            definitions: {
              route: {
                type: 'object',
                properties: {
                  route:        { type: 'string' },
                  page_handle:  { type: 'string' }
                },
                required: [:route, :page_handle]
              }
            },
            type: 'array',
            items: { '$ref': '#/definitions/route' }
          }
        end

      end
    end
  end
end
