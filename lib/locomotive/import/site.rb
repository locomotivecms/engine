module Locomotive
  module Import
    module Site

      def self.process(context)
        site, database = context[:site], context[:database]

        attributes = database['site'].clone.delete_if { |name, value| %w{pages assets content_types asset_collections}.include?(name) }

        site.attributes = attributes

        site.save!
      end

    end
  end
end