module Locomotive
  class Section

    include Locomotive::Mongoid::Document
    include Concerns::Shared::SiteScope
    include Concerns::Shared::Slug
    include Concerns::Shared::JsonAttribute

    ## fields ##
    field :name
    field :slug
    field :definition, type: Hash, default: {}
    field :template

    ## validations ##
    validates_presence_of   :name, :slug, :template, :definition
    validates_uniqueness_of :slug, scope: :site_id

    ## named scopes ##
    scope :by_id_or_slug, ->(id_or_slug) { all.or({ _id: id_or_slug }, { slug: id_or_slug }) }

    ## behaviours ##
    slugify_from    :name
    json_attribute  :definition

    ## indexes ##
    index site_id: 1, slug: 1

    ## methods ##

    def touch_site_attribute
      :template_version
    end

    # Example:
    # {
    #   "name": "Header",
    #   "settings": [
    #     {
    #       "label": "Brand name",
    #       "id": "brand",
    #       "type": "string"
    #     }
    #   ],
    #   "blocks": [
    #     {
    #       "name": "Menu item",
    #       "type": "menu_item",
    #       "settings": [
    #         {
    #           "label": "Item item",
    #           "id": "title",
    #           "type": "text"
    #         },
    #         {
    #           "label": "Item link",
    #           "id": "url",
    #           "type": "text"
    #         },
    #         {
    #           "label": "Open a new tab",
    #           "id": "new_tab",
    #           "type": "boolean",
    #           "default": false
    #         }
    #       ]
    #     }
    #   ]
    # }
    def _definition_schema
      {
        id: 'http://www.locomotive.cms/schemas/sections/definition2.json',
        definitions: {
          settings: {
            type: 'object',
            properties: {
              id:       { type: 'string' },
              label:    { '$ref': '#/definitions/locale_string' },
              type:     { enum: ['text', 'image_picker', 'checkbox', 'select', 'url', 'radio', 'content_type', 'content_entry', 'hint', 'integer'] },
              default:  {}
            },
            required: [:id, :type]
          },
          blocks: {
            type: 'object',
            properties: {
              name:       { '$ref': '#/definitions/locale_string' },
              type:       { type: 'string' },
              limit:      { type: 'integer' },
              settings:   { type: 'array', items: { '$ref': '#/definitions/settings' }, default: [] }
            },
            required: [:type, :name]
          },
          preset_blocks: {
            type: 'object',
            properties: {
              type:       { type: 'string' }
            },
            required: [:type]
          },
          preset: {
            type: 'object',
            properties: {
              name:       { '$ref': '#/definitions/locale_string' },
              category:   { '$ref': '#/definitions/locale_string' },
              settings:   { type: 'object' },
              blocks:     { type: 'array', items: { '$ref': '#/definitions/preset_blocks'} }
            },
            required: [:name, :category]
          },
          locale_string: {
             anyOf: [
              { type: 'string' },
              {
                type: 'object',
                patternProperties: {
                  '^[a-z]*(-[A-z]*)*$': { 'type': 'string' }
                },
                additionalProperties: false
              }
            ]
          }
        },
        type: 'object',
        properties: {
          name:             { '$ref': '#/definitions/locale_string' },
          class:            { type: 'string' },
          settings:         { type: 'array', items: { '$ref': '#/definitions/settings' } },
          presets:          { type: 'array', items: { '$ref': '#/definitions/preset' } },
          blocks:           { type: 'array', items: { '$ref': '#/definitions/blocks' } },
          max_blocks:       { type: 'integer' },
          blocks_display:   { enum: ['list', 'tree'] },
          max_blocks_depth: { type: 'integer' },
          default:          {
            type: 'object',
            properties: {
              settings:  { type: 'object' },
              blocks:    { type: 'array' }
            },
            required: [:settings]
          }
        },
        required: [:name, :settings]
      }
    end

  end
end
