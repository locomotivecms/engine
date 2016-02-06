module Locomotive
  module CurrentSiteMetafieldsHelper

    def current_site_metafields_schema
      @current_site_metafields_schema ||= @current_site.metafields_schema.map do |g|
        SchemaGroup.new(@current_site, g)
      end.sort { |g| g.position }
    end

    class SchemaGroup

      def initialize(site, attributes)
        @site, @attributes = site, attributes
      end

      def name
        @attributes['name']
      end

      def label
        t(@attributes['label'])
      end

      def dom_id
        t(@attributes['label']).downcase.dasherize
      end

      def position
        @attributes['position']
      end

      def fields
        @fields ||= @attributes['fields'].map do |f|
          SchemaField.new(@site, name, f)
        end.sort { |f| f.position }
      end

      protected

      def t(value)
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
        t(@attributes['label'] || @attributes['name'])
      end

      def hint
        t(@attributes['hint'])
      end

      def type
        :string # TODO
      end

      def position
        @attributes['position']
      end

      def value
        t((@site.metafields[@namespace] || {})[name], ::Mongoid::Fields::I18n.locale.to_s)
      end

      protected

      def t(value, locale = I18n.locale.to_s)
        value.is_a?(Hash) ? value[locale] || value['default'] : value
      end

    end

  end
end
