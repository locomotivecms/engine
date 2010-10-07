module Locomotive
  module Import
    module AssetCollections

      def self.process(context)
        site, database = context[:site], context[:database]

        asset_collections = database['site']['asset_collections']

        return if asset_collections.nil?

        asset_collections.each do |name, attributes|
          puts "....asset_collection = #{attributes['slug']}"

          asset_collection = site.asset_collections.where(:slug => attributes['slug']).first

          asset_collection ||= self.build_asset_collection(site, attributes.merge(:name => name))

          self.add_or_update_fields(asset_collection, attributes['fields'])

          asset_collection.save!

          site.reload
        end
      end

      def self.build_asset_collection(site, data)
        attributes = { :internal => false }.merge(data)

        attributes.delete_if { |name, value| %w{fields assets}.include?(name) }

        site.asset_collections.build(attributes)
      end

      def self.add_or_update_fields(asset_collection, fields)
        fields.each do |name, data|
          attributes = { :_alias => name, :label => name.humanize, :kind => 'string' }.merge(data).symbolize_keys

          field = asset_collection.asset_custom_fields.detect { |f| f._alias == attributes[:_alias] }

          field ||= asset_collection.asset_custom_fields.build(attributes)

          field.send(:set_unique_name!) if field.new_record?

          field.attributes = attributes
        end
      end

    end
  end
end