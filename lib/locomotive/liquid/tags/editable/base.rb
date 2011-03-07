module Locomotive
  module Liquid
    module Tags
      module Editable
        class Base < ::Liquid::Block

          Syntax = /(#{::Liquid::QuotedFragment})(\s*,\s*#{::Liquid::Expression}+)?/

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @slug = $1.gsub('\'', '')
              @options = { :assignable => true }
              markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/^'/, '').gsub(/'$/, '') }
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'editable_xxx' - Valid syntax: editable_xxx <slug>(, <options>)")
            end

            super
          end

          def end_tag
            super
            
            if @context[:page].present?
              @context[:page].add_or_update_editable_element({
                :block => @context[:current_block].try(:name),
                :slug => @slug,
                :hint => @options[:hint],
                :default_attribute => @options[:default],
                :default_content => default_content,
                :assignable => @options[:assignable],
                :disabled => false,
                :from_parent => false
              }, document_type)
            end
          end

          def render(context)
            current_page = context.registers[:page]

            element = current_page.find_editable_element(context['block'].try(:name), @slug)
            
            if element.present?
              render_element(context, element)
            else
              Locomotive.logger "[editable element] missing element `#{context['block'].try(:name)}` / #{@slug} on #{current_page.fullpath}"
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
          
          
          def default_content
            if @options[:default].present?
              @context[:page].send(@options[:default])
            else
              @nodelist.first.to_s
            end
          end

        end

      end
    end
  end
end
