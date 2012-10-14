module Locomotive
  module Liquid
    module Tags
      module Editable
        class Base < ::Liquid::Block

          Syntax = /(#{::Liquid::QuotedFragment})(\s*,\s*#{::Liquid::Expression}+)?/

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @slug = $1.gsub('\'', '')
              @options = { :fixed => false }
              markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/^'/, '').gsub(/'$/, '') }
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'editable_xxx' - Valid syntax: editable_xxx <slug>(, <options>)")
            end

            super
          end

          def end_tag
            super

            if @context[:page].present?
              @context[:page].add_or_update_editable_element(default_element_attributes, document_type)
            end
          end

          def render(context)
            current_page = context.registers[:page]

            element = current_page.find_editable_element(context['block'].try(:name), @slug)

            if element.present?
              render_element(context, element)
            else
              Locomotive.log :error, "[editable element] missing element `#{context['block'].try(:name)}` / #{@slug} on #{current_page.fullpath}"
              ''
            end
          end

          protected

          def default_element_attributes
            {
              :block         => self.current_block_name,
              :slug          => @slug,
              :hint          => @options[:hint],
              :priority      => @options[:priority] || 0,
              :fixed         => !!@options[:fixed],
              :disabled      => false,
              :from_parent   => false,
              :_type         => self.document_type.to_s
            }
          end

          def render_element(element)
            raise 'FIXME: has to be overidden'
          end

          def document_type
            raise 'FIXME: has to be overidden'
          end

          def current_block_name
            @options[:block] || @context[:current_block].try(:name)
          end

          def render_default_content(context)
            begin
              render_all(@nodelist, context).join(' ')
            rescue
              raise ::Liquid::SyntaxError.new("Error in the #{self.current_block_name || 'default'} block for the #{@slug} editable_element - No liquid tags are allowed inside.")
            end
          end
        end

      end
    end
  end
end
