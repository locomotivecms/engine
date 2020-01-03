module Locomotive
  module Steam

    class LiquidParserWithCacheService < LiquidParserService

      UNMARSHALABLE_OPTIONS = %i(parser page parent_finder snippet_finder section_finder).freeze

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
        _template = template.dup

        # delete the unmarshalable options of the Liquid Template
        delete_unmarshalable_options(_template)

        # get rid of options in any tags/blocks of the document
        # because options can not be marshaled
        clean_template!(_template.root)

        Marshal.dump(_template)
      end

      def clean_template!(node)
        remove_unmarshalable_parse_context_options(node)

        # special case
        clean_template!(node.descendant) if node.respond_to?(:descendant) && node.descendant

        if node.respond_to?(:nodelist) && node.nodelist
          node.nodelist.each do |_node|
            clean_template!(_node)
          end
        end

        # FIXME: To debug marshalling errors, find the node element which can't be marshaled with `Marshal.dump(node)`
      end

      def remove_unmarshalable_parse_context_options(node)
        parse_context = node.instance_variable_get(:@parse_context)

        return if parse_context.nil?

        unless parse_context[:inherited_blocks].blank?
          remove_unmarshalable_parse_context_options_from_inherited_blocks(parse_context)
        end

        delete_unmarshalable_options(parse_context)
      end

      def remove_unmarshalable_parse_context_options_from_inherited_blocks(parse_context)
        parse_context[:inherited_blocks].values.each do |blocks|
          (blocks.respond_to?(:has_key?) ? blocks.values : blocks).each do |block|
            _parse_context = block.instance_variable_get(:@parse_context)
            delete_unmarshalable_options(_parse_context)
          end
        end
      end

      def delete_unmarshalable_options(template_or_parse_context)
        options = template_or_parse_context.instance_variable_get(:@template_options) ||
                  template_or_parse_context.instance_variable_get(:@options)
        options.delete_if { |name, _| UNMARSHALABLE_OPTIONS.include?(name) }
      end

    end

  end
end
