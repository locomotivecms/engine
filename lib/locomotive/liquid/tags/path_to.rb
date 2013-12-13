module Locomotive
  module Liquid
    module Tags
      class PathTo < ::Liquid::Tag

        include PathHelper

        def render(context)
          render_path(context)
        end

        def wrong_syntax!
          raise SyntaxError.new("Syntax Error in 'path_to' - Valid syntax: path_to <page|page_handle|content_entry>(, locale: [fr|de|...], with: <page_handle>")
        end

      end

      ::Liquid::Template.register_tag('path_to', PathTo)
    end
  end
end
