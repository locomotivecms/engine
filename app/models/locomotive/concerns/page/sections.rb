module Locomotive
  module Concerns
    module Page
      module Sections

        extend ActiveSupport::Concern
        include Concerns::Shared::JsonAttribute

        included do

          ## fields ##
          field :sections_dropzone_content, type: Array, default: [], localize: true
          field :sections_content, type: Hash, default: {}, localize: true

          ## behaviours ##
          json_attribute  :sections_dropzone_content
          json_attribute  :sections_content
        end

        def all_sections_content
          (self.sections_dropzone_content || []).map.each_with_index do |section, index|
            # based on the mechanism that Steam uses to generate the anchors
            _anchor = (section['anchor'] || "dropzone-#{index}") + '-section'
            section.merge({ 'anchor' => _anchor })
          end +
          (self.sections_content || {}).map do |(section_id, section)|
            section.merge({ 'anchor' => "page-#{section_id}-section" })
          end
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
        def _sections_dropzone_content_schema
          {
            id: 'http://www.locomotive.cms/schemas/page/sections_dropzone_content.json',
            definitions: {
              section: {
                type: 'object',
                properties: {
                  type:     { type: 'string' },
                  settings: { type: 'object' },
                  blocks:   { type: 'array' }
                },
                required: [:type, :settings, :blocks]
              }
            },
            type: 'array',
            items: { '$ref': '#/definitions/section' }
          }
        end

        # Example:
        #
        # {
        #   "banner": {
        #     "settings": {
        #       "title": "Hello world!",
        #       "backgroundImage": "/picture.png"
        #     },
        #     "blocks": []
        #   }
        # }
        #
        def _sections_content_schema
          {
            id: 'http://www.locomotive.cms/schemas/page/sections_content.json',
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
