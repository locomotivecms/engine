module Locomotive
  module Import
    module Site

      def self.process(database, site, theme_path)
        attributes = database['site'].clone.delete_if { |name, value| %w{pages content_types asset_collections}.include?(name) }

        site.attributes = attributes

        site.save!

        puts "site errors = #{site.errors.inspect}"
      end

    end
  end
end