module Locomotive
  module Liquid
    module Tags
      class Extends < ::Liquid::Block
        Syntax = /(#{::Liquid::QuotedFragment})/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @template_name = $1
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'extends' - Valid syntax: extends [template]")
          end

          super

          @blocks = @nodelist.inject({}) do |m, node|
            m[node.name] = node if node.is_a?(Locomotive::Liquid::Tags::Block); m
          end
        end

        def parse(tokens)
          parse_all(tokens)
        end

        def render(context)
          template, parent_blocks = load_template(context)

          @blocks.each do |name, block|
            if pb = parent_blocks[name]
              pb.parent = block.parent
              pb.add_parent(pb.nodelist)
              pb.nodelist = block.nodelist
            else
              if is_extending?(template)
                template.root.nodelist << block
              end
            end
          end

          template.render(context)
        end

        private

        def parse_all(tokens)
          @nodelist ||= []
          @nodelist.clear

          while token = tokens.shift
            case token
            when /^#{::Liquid::TagStart}/
              if token =~ /^#{::Liquid::TagStart}\s*(\w+)\s*(.*)?#{::Liquid::TagEnd}$/
                # fetch the tag from registered blocks
                if tag = ::Liquid::Template.tags[$1]
                  @nodelist << tag.new($1, $2, tokens)
                else
                  # this tag is not registered with the system
                  # pass it to the current block for special handling or error reporting
                  unknown_tag($1, $2, tokens)
                end
              else
                raise ::Liquid::SyntaxError, "Tag '#{token}' was not properly terminated with regexp: #{TagEnd.inspect} "
              end
            when /^#{::Liquid::VariableStart}/
              @nodelist << create_variable(token)
            when ''
              # pass
            else
              @nodelist << token
            end
          end
        end

        def load_template(context)
          layout = context.registers[:site].layouts.where(:slug => context[@template_name]).first
          [layout.template, layout.template.send(:instance_variable_get, :"@parent_blocks")]
        end

        def is_extending?(template)
          template.root.nodelist.any? { |node| node.is_a?(Extends) }
        end

      end

      ::Liquid::Template.register_tag('extends', Extends)
    end
  end
end