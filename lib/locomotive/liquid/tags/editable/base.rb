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
                :block                => @context[:current_block].try(:name),
                :slug                 => @slug,
                :hint                 => @options[:hint],
                :priority             => @options[:priority] || 0,
                :default_attribute    => @options[:default],
                :default_content      => default_content_option,
                :assignable           => @options[:assignable],
                :disabled             => false,
                :from_parent          => false,
                :_type                => self.document_type.to_s
              }, document_type)
            end
          end

          def render(context)
            current_page = context.registers[:page]

            element = current_page.find_editable_element(context['block'].try(:name), @slug)

            if element.present?
              unless element.default_content.present?
                element.default_content = render_default_content(context)
              end
              render_element(context, element)
            else
              Locomotive.log :error, "[editable element] missing element `#{context['block'].try(:name)}` / #{@slug} on #{current_page.fullpath}"
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

          def default_content_option
            result = nil
            if @options[:default].present?
              result = @context[:page].send(@options[:default])
            end
            result
          end

          def render_default_content(context)
            render_all(@nodelist, context).join(' ')
          end
        end

      end
    end
  end
end
