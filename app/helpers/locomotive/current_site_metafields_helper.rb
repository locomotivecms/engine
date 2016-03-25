module Locomotive
  module CurrentSiteMetafieldsHelper

    def current_site_metafields_schema
      @site_metafields_schema ||= @site.metafields_schema.map do |g|
        SchemaGroup.new(@site, g)
      end.sort_by(&:_position)
    end

    class SchemaGroup

      def initialize(site, attributes)
        @site, @attributes = site, attributes
      end

      def _name
        @attributes['name'].downcase.underscore.gsub(' ', '_')
      end

      alias :dom_id :_name

      def model_name
        ActiveModel::Name.new(self, nil, _name)
      end

      def _label
        _t(@attributes['label'] || @attributes['name'].humanize)
      end

      def _position
        @attributes['position']
      end

      def _fields
        @fields ||= @attributes['fields'].map do |f|
          SchemaField.new(@site, _name, f)
        end.sort_by(&:position)
      end

      def method_missing(name, *args, &block)
        if field = _fields.find { |f| f.name == name.to_s }
          field.value
        else
          super
        end
      end

      protected

      def _t(value)
        value.is_a?(Hash) ?  value[I18n.locale.to_s] || value['default'] : value
      end

    end

    class SchemaField

      def initialize(site, namespace, attributes)
        @site, @namespace, @attributes = site, namespace, attributes
      end

      def name
        t(@attributes['name']).downcase.underscore.gsub(' ', '_')
      end

      def label
        t(@attributes['label'] || @attributes['name'].humanize)
      end

      def hint
        t(@attributes['hint'])
      end

      def type
        @type ||= case (type = @attributes['type'].try(:to_sym))
        when :boolean then :toggle
        when :text    then :rte
        else
          type || :string
        end
      end

      def input_options
        case type
        when :select then { collection: select_collection }
        else
          {}
        end.merge(default_input_options)
      end

      def select_collection
        @attributes['select_options'].map do |name, label|
          label = { 'default' => name.humanize } if label.blank?
          [(t(label) || name).html_safe, name]
        end
      end

      def position
        @attributes['position']
      end

      def value
        t((@site.metafields[@namespace] || {})[name], ::Mongoid::Fields::I18n.locale.to_s)
      end

      def default_input_options
        {
          label:      self.label,
          hint:       self.hint.try(:html_safe),
          as:         self.type,
          required:   false
        }
      end

      protected

      def t(value, locale = I18n.locale.to_s)
        value.is_a?(Hash) ? value[locale] || value['default'] : value
      end

    end

  end
end
