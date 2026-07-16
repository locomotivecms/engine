module Locomotive
  module Steam

    class LiquidParserWithCacheService < LiquidParserService

      attr_accessor_initialize :current_site, :parent_finder, :snippet_finder, :locale

      def parse(page)
        return super unless current_site.cache_enabled

        read_template_from_cache(page) || write_template_in_cache(page, super)
      end

      def cache_key(page)
        "#{Locomotive::VERSION}/site/#{current_site._id}/template/#{current_site.template_version.to_i}/page/#{page._id}/#{locale}"
      end

      private

      def read_template_from_cache(page)
        if marshaled = Rails.cache.read(cache_key(page))
          Marshal.load(marshaled)
        end
      end

      def write_template_in_cache(page, template)
        begin
          Rails.cache.write(cache_key(page), marshal(template))
        rescue Exception => e
          Rails.logger.warn "Could not marshal #{cache_key(page)}, error: #{e.message}"
          Rails.logger.debug e.backtrace.join("\n")
        end

        template
      end

      def marshal(template)
        # The unmarshalable parse-time state is stripped and restored by
        # Locomotive::Steam::Liquid::MarshalCache (locomotivecms_steam).
        # Consequence: a cache hit carries no parse-time discovery services --
        # editable elements/sections discovery is considered done by the cold
        # parse that wrote the cache entry.
        Marshal.dump(template)
      end

    end

  end
end
