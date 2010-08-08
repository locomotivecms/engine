module Locomotive
  module Liquid
    module Tags
      class Block < ::Liquid::Block
        Syntax = /(\w+)/

        attr_accessor :parent
        attr_reader :name

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @name = $1
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'block' - Valid syntax: block [name]")
          end
          # puts "** [Block/initialize] #{tag_name}, #{@name}, #{tokens.inspect}"

          super if tokens
        end

        def render(context)
          # puts "** [Block/render] #{@name} / #{@parent.inspect}"
          context.stack do
            context['block'] = Locomotive::Liquid::Drops::Block.new(self)

            render_all(@nodelist, context)
          end
        end

        def add_parent(nodelist)
          if parent
            parent.add_parent(nodelist)
          else
            self.parent = self.class.new(@tag_name, @name, nil)
            parent.nodelist = nodelist
          end
        end

        def call_super(context)
          if parent
            parent.render(context)
          else
            ''
          end
        end

      end

      ::Liquid::Template.register_tag('block', Block)
    end
  end
end