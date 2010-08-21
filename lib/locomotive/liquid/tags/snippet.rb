module Locomotive
  module Liquid
    module Tags

      class Snippet < ::Liquid::Include

        attr_accessor :partial

        def initialize(tag_name, markup, tokens, context)
          super

          snippet = context[:site].snippets.where(:slug => @template_name.gsub('\'', '')).first

          if snippet
            @partial = ::Liquid::Template.parse(snippet.template, context)
            @partial.root.context.clear
          end
        end

        def render(context)
          return '' if @partial.nil?

          variable = context[@variable_name || @template_name[1..-2]]

          context.stack do
            @attributes.each do |key, value|
              context[key] = context[value]
            end

            output = (if variable.is_a?(Array)
              variable.collect do |variable|
                context[@template_name[1..-2]] = variable
                @partial.render(context)
              end
            else
              context[@template_name[1..-2]] = variable
              @partial.render(context)
            end)

            output
          end
        end
      end

      ::Liquid::Template.register_tag('include', Snippet)
    end
  end
end
