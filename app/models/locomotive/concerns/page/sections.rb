module Locomotive
  module Concerns
    module Page
      module Sections

        extend ActiveSupport::Concern
        include Concerns::Shared::JsonAttribute

        included do

          ## fields ##
          field :sections_content, type: Array, default: [], localize: true

          ## behaviours ##
          json_attribute  :sections_content
        end

        private

        # Example:
        #
        # [
        #   {
        #     "name": "Image with text overlay",
        #     "type": "hero",
        #     "settings": {
        #       "title": "Hello world",
        #       "image": "/banner.png"
        #     },
        #     "blocks": []
        #   },
        #   {
        #     "type": "Slideshow",
        #     "settings": {},
        #     "blocks": [
        #       {
        #         "settings": {
        #           "slide": "/slide1.png"
        #         }
        #       },
        #       {
        #         "settings": {
        #           "slide": "/slide2.png"
        #         }
        #       }
        #     ]
        #   }
        # ]
        #
        def _sections_content_schema
          {
            id: 'http://www.locomotive.cms/schemas/page/sections_content.json',
            definitions: {
              section: {
                type: 'object',
                properties: {
                  name:     { type: 'string' },
                  type:     { type: 'string' },
                  settings: { type: 'object' },
                  blocks:   { type: 'array' }
                },
                required: [:name, :type, :settings, :blocks]
              }
            },
            type: 'array',
            items: { '$ref': '#/definitions/section' }
          }
        end

      end
    end
  end
end
