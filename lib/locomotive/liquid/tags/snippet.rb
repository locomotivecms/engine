module Locomotive
  module Liquid
    module Tags

      class Snippet < ::Liquid::Include

        attr_accessor :slug
        attr_accessor :partial

        def initialize(tag_name, markup, tokens, context)
          super

          @slug = @template_name.gsub('\'', '')

          if @context[:snippets].present?
            (@context[:snippets] << @slug).uniq! 
          else
            @context[:snippets] = [@slug]
          end

          if @context[:site].present?
            snippet = @context[:site].snippets.where(:slug => @slug).first
            self.refresh(snippet) if snippet
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

        def refresh(snippet, context = {})
          if snippet.destroyed?
            @snippet_id = nil
            @partial = nil
          else
            @snippet_id = snippet.id
            @partial = ::Liquid::Template.parse(snippet.template, @context.clone)
            @partial.root.context.clear
          end
        end

      end

      ::Liquid::Template.register_tag('include', Snippet)
    end
  end
end
