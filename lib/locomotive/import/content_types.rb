module Locomotive
  module Import
    module ContentTypes

      def self.process(context)
        site, database = context[:site], context[:database]

        content_types = database['site']['content_types']

        return if content_types.nil?

        content_types.each do |name, attributes|
          content_type = site.content_types.where(:slug => attributes['slug']).first

          content_type ||= self.create_content_type(site, attributes.merge(:name => name))

          self.add_or_update_fields(content_type, attributes['fields'])

          content_type.save!

          site.reload
        end
      end

      def self.create_content_type(site, data)
        attributes = { :order_by => 'manually' }.merge(data)

        attributes.delete_if { |name, value| %w{fields contents}.include?(name) }

        site.content_types.build(attributes)
      end

      def self.add_or_update_fields(content_type, fields)
        fields.each do |name, data|
          attributes = { :label => name.humanize, :_name => name, :kind => 'String' }.merge(data).symbolize_keys

          field = content_type.content_custom_fields.detect { |f| f._name == attributes[:_name] }

          field ||= content_type.content_custom_fields.build(attributes)

          field.attributes = attributes
        end
      end

    end
  end
end