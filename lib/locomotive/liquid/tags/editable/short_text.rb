module Locomotive
  module Liquid
    module Tags
      module Editable
        class ShortText < ::Liquid::Block

          Syntax = /(#{::Liquid::QuotedFragment})(\s*,\s*#{::Liquid::Expression}+)?/

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @slug = $1.gsub('\'', '')
              @options = {}
              markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/^'/, '').gsub(/'$/, '') }
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'editable_short_text' - Valid syntax: editable_short_text <slug>(, <options>)")
            end

            super
          end

          def end_tag
            @context[:page].add_or_update_editable_element({
              :kind => self.kind,
              :block => @context[:current_block].try(:name),
              :slug => @slug,
              :hint => @options[:hint],
              :default_content => @nodelist.first.to_s,
              :disabled => false,
              :from_parent => false
            })
          end

          def render(context)
            current_page = context.registers[:page]

            element = current_page.find_editable_element(context['block'].try(:name), @slug)

            if element
              element.content
            else
              Locomotive.logger "[editable short text] missing editable short text #{context[:block].name} / #{@slug}"
              ''
            end
          end

          protected

          def kind
            self.class.name.demodulize
          end

        end

        ::Liquid::Template.register_tag('editable_short_text', ShortText)
      end
    end
  end
end
