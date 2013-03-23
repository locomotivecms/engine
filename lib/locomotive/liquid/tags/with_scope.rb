module Locomotive
  module Liquid
    module Tags

      # Filter a collection
      #
      # Usage:
      #
      # {% with_scope main_developer: 'John Doe', active: true %}
      #   {% for project in contents.projects %}
      #     {{ project.name }}
      #   {% endfor %}
      # {% endwith_scope %}
      #

      class WithScope < ::Liquid::Block

        TagAttributes = /(\w+|\w+\.\w+)\s*\:\s*(#{::Liquid::QuotedFragment})/

        def initialize(tag_name, markup, tokens, context)
          @attributes = HashWithIndifferentAccess.new
          markup.scan(TagAttributes) do |key, value|
            key = key_to_h4s_symbol(key)
            @attributes[key] = value
          end
          super
        end

        def render(context)
          context.stack do
            context['with_scope'] = decode(@attributes.clone, context)
            render_all(@nodelist, context)
          end
        end

        private

        def decode(attributes, context)
          attributes.each_pair do |key, value|
            attributes[key] = context[value]
          end
        end

        def key_to_h4s_symbol(key)
          _key, _operator = key.split('.')

          if %w(all exists gt gte in lt lte ne nin size near within).include?(_operator)
            _key.to_s.to_sym.send(_operator.to_sym)
          else
            _key
          end
        end
      end

      ::Liquid::Template.register_tag('with_scope', WithScope)
    end
  end
end
