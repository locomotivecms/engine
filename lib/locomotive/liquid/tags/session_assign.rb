module Locomotive
  module Liquid
    module Tags

      # Assign sets a variable in your session.
      #
      #   {% session_assign foo = 'monkey' %}
      #
      # You can then use the variable later in the page.
      #
      #   {{ session.foo }}
      #
      class SessionAssign < ::Liquid::Tag
        Syntax = /(#{::Liquid::VariableSignature}+)\s*=\s*(#{::Liquid::QuotedFragment}+)/

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @to = $1
            @from = $2
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'session_assign' - Valid syntax: assign [var] = [source]")
          end

          super
        end

        def render(context)
          controller = context.registers[:controller]

          controller.session[@to.to_sym] = context[@from]
          ''
        end

      end

      ::Liquid::Template.register_tag('session_assign', SessionAssign)
    end
  end
end