require 'ostruct'

module Locomotive
  module Import
    class ContentTypes < Base

      def process
        return if content_types.nil?

        contents_with_associations, content_types_with_associations = [], []

        content_types.each do |name, attributes|
          self.log "[content_types] slug = #{attributes['slug']}"

          content_type = site.content_types.where(:slug => attributes['slug']).first

          content_type_name = attributes['name'] || name

          if content_type.nil?
            content_type = self.build_content_type(attributes.merge(:name => content_type_name))
          else
            self.update_attributes(content_type, attributes.merge(:name => content_type_name))
          end

          self.add_or_update_fields(content_type, attributes['fields'])

          if content_type.content_custom_fields.any? { |f| ['has_many', 'has_one'].include?(f.kind) }
            content_types_with_associations << content_type
          end

          self.set_highlighted_field_name(content_type)

          self.set_order_by_value(content_type)

          self.set_group_by_value(content_type)

          if options[:samples] && attributes['contents']
            contents_with_associations += self.insert_samples(content_type, attributes['contents'])
          end

          content_type.save!
        end

        # look up for associations and replace their target field by the real class name
        self.replace_target(content_types_with_associations)

        # update all the contents with associations now that every content is stored in mongodb
        self.insert_samples_with_associations(contents_with_associations)

        # invalidate the cache of the dynamic classes (custom fields)
        site.content_types.all.collect { |c| c.invalidate_content_klass; c.fetch_content_klass }
      end

      protected

      def content_types
        database['site']['content_types']
      end

      def cleanse_attributes(data)
        attributes = { :group_by_field_name => data.delete('group_by') }.merge(data)

        attributes.delete_if { |name, value| %w{fields contents}.include?(name) }
        attributes
      end

      def build_content_type(data)
        attributes = cleanse_attributes(data)
        site.content_types.build(attributes)
      end

      def update_attributes(content_type, data)
        attributes = cleanse_attributes(data)
        content_type.update_attributes!(attributes)
      end

      def add_or_update_fields(content_type, fields)
        fields.each_with_index do |data, position|
          name, data = data.keys.first, data.values.first

          reverse_lookup = data.delete('reverse')

          attributes = { :_alias => name, :label => name.humanize, :kind => 'string', :position => position }.merge(data).symbolize_keys

          field = content_type.content_custom_fields.detect { |f| f._alias == attributes[:_alias] }

          field ||= content_type.content_custom_fields.build(attributes)

          field.send(:set_unique_name!) if field.new_record?

          field.attributes = attributes

          field[:kind] = field[:kind].downcase # old versions of the kind field are capitalized

          field[:tmp_reverse_lookup] = reverse_lookup # use the ability in mongoid to set free attributes on the fly
        end
      end

      def replace_target(content_types)
        content_types.each do |content_type|
          content_type.content_custom_fields.each do |field|
            next unless ['has_many', 'has_one'].include?(field.kind)

            target_content_type = site.content_types.where(:slug => field.target).first

            if target_content_type
              field.target = target_content_type.content_klass.to_s

              if field[:tmp_reverse_lookup]
                field.reverse_lookup = field[:tmp_reverse_lookup]
                field.reverse_lookup = field.safe_reverse_lookup # make sure we store the true value
              end
            end
          end

          content_type.save
        end
      end

      def insert_samples(content_type, contents)
        contents_with_associations = []

        contents.each_with_index do |data, position|
          value, attributes = data.is_a?(Array) ? [data.first, data.last] : [data.keys.first, data.values.first]

          associations = []

          # build with default attributes
          content = content_type.contents.where(content_type.highlighted_field_name.to_sym => value).first

          if content.nil?
            content = content_type.contents.build(content_type.highlighted_field_name.to_sym => value, :_position_in_list => position)
          end

          %w(_permalink seo_title meta_description meta_keywords).each do |attribute|
            new_value = attributes.delete(attribute)

            next if new_value.blank?

            content.send("#{attribute}=".to_sym, new_value)
          end

          attributes.each do |name, value|
            field = content_type.content_custom_fields.detect { |f| f._alias == name }

            next if field.nil? # the attribute name is not related to a field (name misspelled ?)

            kind = field.kind

            if ['has_many', 'has_one'].include?(kind)
              associations << OpenStruct.new(:name => name, :kind => kind, :value => value, :target => field.target)
              next
            end

            value = (case kind
            when 'file'     then self.open_sample_asset(value)
            when 'boolean'  then Boolean.set(value)
            when 'date'     then value.is_a?(Date) ? value : Date.parse(value)
            when 'category'
              if field.category_items.detect { |item| item.name == value }.nil?
                field.category_items.build :name => value
              end
              value
            else # string, text
              value
            end)

            content.send("#{name}=", value)
          end

          content.send(:set_slug)

          content.save(:validate => false)

          contents_with_associations << [content, associations] unless associations.empty?

          self.log "insert content '#{content.send(content_type.highlighted_field_name.to_sym)}'"
        end

        contents_with_associations
      end

      def insert_samples_with_associations(contents)
        contents.each do |content_information|
          next if content_information.empty?

          content, associations = content_information

          content = content._parent.reload.contents.find(content._id) # target should be updated

          associations.each do |association|
            target_content_type = site.content_types.where(:slug => association.target).first

            next if target_content_type.nil?

            value = (case association.kind
            when 'has_one' then
              target_content_type.contents.detect { |c| c.highlighted_field_value == association.value }
            when 'has_many' then
              association.value.collect do |v|
                target_content_type.contents.detect { |c| c.highlighted_field_value == v }._id
              end
            end)

            content.send("#{association.name}=", value)
          end

          content.save
        end
      end

      def set_highlighted_field_name(content_type)
        field = content_type.content_custom_fields.detect { |f| f._alias == content_type.highlighted_field_name.to_s }

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
