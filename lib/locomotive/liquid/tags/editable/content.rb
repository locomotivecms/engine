module Locomotive
  module Liquid
    module Tags
      module Editable
        class Content < ::Liquid::Tag

          Syntax = /(#{::Liquid::Expression}+)?/

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @slug = $1
              @options = { :inherit => false }
              markup.scan(::Liquid::TagAttributes) { |key, value| @options[key.to_sym] = value.gsub(/"|'/, '') }
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'content' - Valid syntax: slug")
            end

            super
          end

          def render(context)
            page = context.registers[:page]
            element = find_element(page)

            if element.nil? && @options[:inherit] != false
              while page.parent.present? && element.nil?
                page = page.parent
                element = find_element(page)
              end
            end

            if element.present?
              return element.content
            else
              raise ::Liquid::SyntaxError.new("Error in 'content' - Can't find editable element called `#{@slug}`")
            end
          end

          def find_element(page)
            page.editable_elements.where(:slug => @slug).first
          end

        end

        ::Liquid::Template.register_tag('content', Content)
      end
    end
  end
end