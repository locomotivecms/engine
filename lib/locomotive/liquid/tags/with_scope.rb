module Locomotive
  module Liquid
    module Tags

      # Filter a collection
      #
      # Usage:
      #
      # {% with_scope main_developer: 'John Doe', providers.in: ['acme'], started_at.le: today, active: true %}
      #   {% for project in contents.projects %}
      #     {{ project.name }}
      #   {% endfor %}
      # {% endwith_scope %}
      #

      class WithScope < Solid::Block

        OPERATORS = %w(all exists gt gte in lt lte ne nin size near within)

        SYMBOL_OPERATORS_REGEXP = /(\w+\.(#{OPERATORS.join('|')})){1}\s*\:/

        # register the tag
        tag_name :with_scope

        def initialize(tag_name, arguments_string, tokens, context = {})
          # convert symbol operators into valid ruby code
          arguments_string.gsub!(SYMBOL_OPERATORS_REGEXP, ':"\1" =>')

          super(tag_name, arguments_string, tokens, context)
        end

        def display(options = {}, &block)
          current_context.stack do
            current_context['with_scope'] = self.decode(options)
            yield
          end
        end

        protected

        def decode(options)
          HashWithIndifferentAccess.new.tap do |hash|
            options.each do |key, value|
              _key, _operator = key.to_s.split('.')

              # _slug instead of _permalink
              _key = '_slug' if _key == '_permalink'

              # key to h4s symbol
              _key = _key.to_s.to_sym.send(_operator.to_sym) if _operator

              hash[_key] = value
            end
          end
        end
      end

    end
  end
end
