module Locomotive
  module Import
    class AssetCollections < Base

      def process
        asset_collections = database['site']['asset_collections']

        return if asset_collections.nil?

        asset_collections.each do |name, attributes|
          self.log "slug = #{attributes['slug']}"

          asset_collection = site.asset_collections.where(:slug => attributes['slug']).first

          asset_collection ||= self.build_asset_collection(attributes.merge(:name => name))

          self.add_or_update_fields(asset_collection, attributes['fields'])

          if options[:samples] && attributes['assets']
            self.insert_samples(asset_collection, attributes['assets'])
          end

          asset_collection.save!

          site.reload
        end
      end

      protected

      def build_asset_collection(data)
        attributes = { :internal => false }.merge(data)

        attributes.delete_if { |name, value| %w{fields assets}.include?(name) }

        site.asset_collections.build(attributes)
      end

      def add_or_update_fields(asset_collection, fields)
        return if fields.blank?

        fields.each_with_index do |data, position|
          name, data = data.keys.first, data.values.first

          attributes = { :_alias => name, :label => name.humanize, :kind => 'string', :position => position }.merge(data).symbolize_keys

          field = asset_collection.asset_custom_fields.detect { |f| f._alias == attributes[:_alias] }

          field ||= asset_collection.asset_custom_fields.build(attributes)

          field.send(:set_unique_name!) if field.new_record?

          field.attributes = attributes
        end
      end

      def insert_samples(asset_collection, assets)
        assets.each_with_index do |data, position|
          value, attributes = data.is_a?(Array) ? [data.first, data.last] : [data.keys.first, data.values.first]

          url = attributes.delete('url')

          # build with default attributes
          asset = asset_collection.assets.build(:name => value, :position => position, :source => self.open_sample_asset(url))

          attributes.each do |name, value|
            field = asset_collection.asset_custom_fields.detect { |f| f._alias == name }

            value = (case field.kind.downcase
            when 'file'     then self.open_sample_asset(value)
            when 'boolean'  then Boolean.set(value)
            else
              value
            end)

            asset.send("#{name}=", value)
          end

          asset.save

          self.log "insert asset '#{asset.name}'"
        end
      end

    end
  end
end