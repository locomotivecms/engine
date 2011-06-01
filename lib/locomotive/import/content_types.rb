module Locomotive
  module Import
    class ContentTypes < Base

      def process
        return if content_types.nil?

        content_types.each do |name, attributes|
          self.log "[content_types] slug = #{attributes['slug']}"

          content_type = site.content_types.where(:slug => attributes['slug']).first

          content_type ||= self.build_content_type(attributes.merge(:name => name))

          self.add_or_update_fields(content_type, attributes['fields'])

          self.set_highlighted_field_name(content_type)

          self.set_order_by_value(content_type)

          self.set_group_by_value(content_type)

          if options[:samples] && attributes['contents']
            self.insert_samples(content_type, attributes['contents'])
          end

          content_type.save!

          site.reload
        end

        # invalidate the cache of the dynamic classes (custom fields)
        ContentType.all.collect(&:invalidate_content_klass)
        AssetCollection.all.collect(&:invalidate_asset_klass)
      end

      protected

      def content_types
        database['site']['content_types']
      end

      def build_content_type(data)
        attributes = { :group_by_field_name => data.delete('group_by') }.merge(data)

        attributes.delete_if { |name, value| %w{fields contents}.include?(name) }

        site.content_types.build(attributes)
      end

      def add_or_update_fields(content_type, fields)
        fields.each_with_index do |data, position|
          name, data = data.keys.first, data.values.first

          attributes = { :_alias => name, :label => name.humanize, :kind => 'string', :position => position }.merge(data).symbolize_keys

          field = content_type.content_custom_fields.detect { |f| f._alias == attributes[:_alias] }

          field ||= content_type.content_custom_fields.build(attributes)

          field.send(:set_unique_name!) if field.new_record?

          field.attributes = attributes
        end
      end

      def insert_samples(content_type, contents)
        contents.each_with_index do |data, position|
          value, attributes = data.is_a?(Array) ? [data.first, data.last] : [data.keys.first, data.values.first]

          # build with default attributes
          content = content_type.contents.build(content_type.highlighted_field_name.to_sym => value, :_position_in_list => position)

          attributes.each do |name, value|
            field = content_type.content_custom_fields.detect { |f| f._alias == name }

            next if field.nil? # the attribute name is not related to a field (name misspelled ?)

            value = (case field.kind.downcase
            when 'file'     then self.open_sample_asset(value)
            when 'boolean'  then Boolean.set(value)
            when 'date'     then value.is_a?(Date) ? value : Date.parse(value)
            when 'category'
              if field.category_items.detect { |item| item.name == value }.nil?
                field.category_items.build :name => value
              end
              value
            else
              value
            end)

            content.send("#{name}=", value)
          end

          content.save

          self.log "insert content '#{content.send(content_type.highlighted_field_name.to_sym)}'"
        end
      end

      def set_highlighted_field_name(content_type)
        field = content_type.content_custom_fields.detect { |f| f._alias == content_type.highlighted_field_name }

        content_type.highlighted_field_name = field._name if field
      end

      def set_order_by_value(content_type)
        self.log "order by #{content_type.order_by}"

        order_by = (case content_type.order_by
        when 'manually', '_position_in_list' then '_position_in_list'
        when 'default', 'created_at' then 'created_at'
        else
          content_type.content_custom_fields.detect { |f| f._alias == content_type.order_by }._name rescue nil
        end)

        self.log "order by (after) #{order_by}"

        content_type.order_by = order_by || '_position_in_list'
      end

      def set_group_by_value(content_type)
        return if content_type.group_by_field_name.blank?

        field = content_type.content_custom_fields.detect { |f| f._alias == content_type.group_by_field_name }

        content_type.group_by_field_name = field._name if field
      end

    end
  end
end