require 'haml/helpers/action_view_mods'

module ActionView
  module Helpers
    module TagHelper

      # Only preserve whitespace in the tag's content: https://github.com/nex3/haml/pull/503
      def content_tag_with_haml_and_preserve(name, content_or_options_with_block = nil, *args, &block)
        return content_tag_without_haml(name, content_or_options_with_block, *args, &block) unless is_haml?

        preserve = haml_buffer.options[:preserve].include?(name.to_s)

        if block_given?
          if block_is_haml?(block) && preserve
            content_tag_without_haml(name, content_or_options_with_block, *args) {preserve(&block)}
          else
            content_tag_without_haml(name, content_or_options_with_block, *args, &block)
          end
        else
          if name == 'textarea'
            tab_down(haml_buffer.tabulation)
          elsif preserve && content_or_options_with_block
            content_or_options_with_block = Haml::Helpers.preserve(content_or_options_with_block)
          end
          content_tag_without_haml(name, content_or_options_with_block, *args, &block)
        end
      end

      alias_method :content_tag_without_haml_and_preserve, :content_tag
      alias_method :content_tag, :content_tag_with_haml_and_preserve
      alias_method :content_tag_with_haml, :content_tag_with_haml_and_preserve
    end
  end
end