module Locomotive
  module Liquid
    module Tags
      module Editable
        class Base < ::Liquid::Block

          Syntax = /(#{::Liquid::QuotedFragment})(\s*,\s*#{::Liquid::Expression}+)?/

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @slug = $1.gsub('\'', '')
              @options = {}
              markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/^'/, '').gsub(/'$/, '') }
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'editable_xxx' - Valid syntax: editable_xxx <slug>(, <options>)")
            end

            super
          end

          def end_tag
            @context[:page].add_or_update_editable_element({
              :block => @context[:current_block].try(:name),
              :slug => @slug,
              :hint => @options[:hint],
              :default_content => @nodelist.first.to_s,
              :disabled => false,
              :from_parent => false
            }, document_type)
          end

          def render(context)
            current_page = context.registers[:page]

            element = current_page.find_editable_element(context['block'].try(:name), @slug)

            if element
              render_element(element)
            else
              Locomotive.logger "[editable element] missing element #{context[:block].name} / #{@slug}"
              ''
            end
          end

          protected

          def render_element(element)
            raise 'FIXME: has to be overidden'
          end

          def document_type
            raise 'FIXME: has to be overidden'
          end

        end

      end
    end
  end
end
