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
    #   "category": "header",
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
              label:    { type: 'string' },
              type:     { enum: ['text', 'image_picker', 'checkbox', 'select', 'url'] },
              default:  {}
            },
            required: [:id, :type]
          },
          blocks: {
            type: 'object',
            properties: {
              name:       { type: 'string' },
              type:       { type: 'string' },
              limit:      { type: 'integer' },
              settings:   { type: 'array', items: { '$ref': '#/definitions/settings' } }
            },
            required: [:type, :name]
          }
        },
        type: 'object',
        properties: {
          name:             { type: 'string' },
          class:            { type: 'string' },
          category:         { type: 'string' },
          settings:         { type: 'array', items: { '$ref': '#/definitions/settings' } },
          blocks:           { type: 'array', items: { '$ref': '#/definitions/blocks' } },
          max_blocks:       { type: 'integer' },
          default:          {
            type: 'object',
            properties: { settings:  { type: 'object' } },
            required: [:settings]
          }
        },
        required: [:name, :settings]
      }
    end

  end
end
