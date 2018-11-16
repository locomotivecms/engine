module Locomotive
  module Concerns
    module Site
      module Sections

        extend ActiveSupport::Concern
        include Concerns::Shared::JsonAttribute

        included do

          ## fields ##
          field :sections_content, type: Hash, default: {}, localize: true

          ## behaviours ##
          json_attribute  :sections_content
        end

        private

        # Example:
        #
        # {
        #   "header": {
        #     "settings": {
        #       "brand_name": "Acme Corp",
        #       "background_color": "#333"
        #     },
        #     "blocks": []
        #   },
        #   "footer": {
        #     "settings": {
        #       "copyright": "2018 (c) copyright Acme LTD"
        #     }
        #   }
        # }
        #
        def _sections_content_schema
          {
            id: 'http://www.locomotive.cms/schemas/site/sections_content.json',
            type: 'object',
            patternProperties: {
              "^[a-z][a-z0-9_]+$" => {
                type: 'object',
                properties: {
                  type:     { type: 'string' },
                  settings: { type: 'object' },
                  blocks:   { type: 'array' }
                },
                additionalProperties: false
              }
            }
          }
        end

      end
    end
  end
end
