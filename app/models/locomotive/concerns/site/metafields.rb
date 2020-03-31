module Locomotive
  module Concerns
    module Site
      module Metafields

        extend ActiveSupport::Concern
        include Concerns::Shared::JsonAttribute

        included do

          ## fields ##
          field :metafields,        type: Hash,   default: {}
          field :metafields_schema, type: Array,  default: []
          field :metafields_ui,     type: Hash,   default: {}

          ## behaviours ##
          json_attribute  :metafields_schema
          json_attribute  :metafields
          json_attribute  :metafields_ui

        end

        def has_metafields?
          !self.metafields_schema.blank?
        end

        def any_localized_metafield?
          return false unless self.has_metafields?

          self.metafields_schema.any? { |g| g['fields'].any? { |f| f['localized'] ==  true } }
        end

        def find_metafield(name)
          return nil if name.blank? || !has_metafields?

          fields = self.metafields_schema.map { |g| g['fields'] }.flatten

          fields.find do |f|
            _name = f['name'].downcase.underscore.gsub(' ', '_')
            _name == name
          end
        end

        def cast_metafields(namespace)
          return nil if namespace.blank? || !has_metafields?

          schema = self.metafields_schema.find { |s| s['name'] == namespace }
          values = self.metafields[namespace]

          return nil if schema.blank? || values.blank?

          values.map do |name, value|
            field = schema['fields'].find { |f| f['name'] == name }
            next unless field
            [name, cast_metafield_value(field, value)]
          end.compact.to_h
        end

        protected

        def _metafields_schema_schema
          {
            'id' => 'http://locomotive.works/schemas/metafields.json',
            'definitions' => {
              'field' => {
                'type' => 'object',
                'properties' => {
                  'name' => { 'type' => 'string', 'pattern' => '^[A-Za-z0-9_]+$', 'not': { 'enum': ['dom_id', 'model_name', 'method_missing', '_name', '_label', '_position', '_fields', '_t'] } },
                  'label' => { 'type' => ['string', 'object'] },
                  'hint' => { 'type' => ['string', 'object'] },
                  'type' => { 'enum' => ['string', 'text', 'integer', 'float', 'image', 'boolean', 'select', 'color'] },
                  'position' => { 'type' => 'integer' },
                  'select_options' => { 'type' => ['object', 'array'] },
                  'localized' => { 'type' => 'boolean' },
                },
                'required' => ['name']
              }
            },
            'type' => 'array',
            'items' => {
              'type' => 'object',
              'properties' => {
                  'name'      => { 'type' => 'string', 'pattern' => '^[A-Za-z0-9_]+$' },
                  'label'     => { 'type' => ['string', 'object'] },
                  'fields'    => { 'type' => 'array', 'items': {'$ref': '#/definitions/field' } },
                  'position'  => { 'type' => 'integer', 'minimum' => 0 }
                },
              'required' => ['name', 'fields']
            }
          }
        end

        def cast_metafield_value(field, value)
          case field['type']
          when 'boolean'
            ['1', 'true', true].include?(value)
          when 'integer'
            Integer(value)
          else
            value
          end
        end

      end

    end
  end
end
