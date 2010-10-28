module Locomotive
  module Import
    class Site < Base

      def process
        attributes = database['site'].clone.delete_if { |name, value| %w{name pages assets content_types asset_collections}.include?(name) }

        site.attributes = attributes

        site.save!
      end

    end
  end
end