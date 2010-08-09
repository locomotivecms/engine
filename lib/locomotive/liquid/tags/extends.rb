module Locomotive
  module Liquid
    module Tags
      class Extends < ::Liquid::Block
        Syntax = /(#{::Liquid::QuotedFragment})/

        # attr_accessor :blocks

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

          # puts "\n** initialize ** Extends #{@template_name} / #{@blocks.inspect}"
        end

        def parse(tokens)
          # puts "[#{@template_name}] parsing...#{tokens.inspect}"
          parse_all(tokens)
        end

        def render(context)
          if OPTIMIZATION
            template, parent_blocks = load_template(context)
          else
            template = load_template(context)
            parent_blocks = find_blocks(template.root)
          end

          # puts "** [Extends/render] @blocks = #{@blocks.inspect} / @nodelist = #{@nodelist.inspect} / parent_blocks = #{parent_blocks.inspect}"

          # BUG: parent blocks and parent template blocks are disconnected (OPTIMIZATION). need to resync them along with @nodelist
          @blocks.each do |name, block|
            # puts "** [Extends/render] #{name}, #{block.inspect}"
            if pb = parent_blocks[name]
              # puts "[#{name}]...found parent block ! #{pb.inspect}"
              pb.parent = block.parent
              # puts "[#{name}] pb.parent = #{pb.parent.inspect} / block.parent = #{block.parent.inspect}"
              pb.add_parent(pb.nodelist)
              # puts "[#{name}] pb.nodelist = #{pb.nodelist.inspect}"
              pb.nodelist = block.nodelist
              # puts "[#{name}] block.nodelist = #{block.nodelist.inspect}"
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
          # puts "** [parse_all] #{tokens.inspect}"

          @nodelist ||= []
          @nodelist.clear

          while token = tokens.shift
            case token
            when /^#{::Liquid::TagStart}/
              if token =~ /^#{::Liquid::TagStart}\s*(\w+)\s*(.*)?#{::Liquid::TagEnd}$/
                # fetch the tag from registered blocks
                if tag = ::Liquid::Template.tags[$1]
                  # puts "** [parse_all] tag = #{$1}, #{$2}"
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
          # puts "** load_template (#{context[@template_name]})"
          layout = context.registers[:site].layouts.where(:slug => context[@template_name]).first
          if OPTIMIZATION
            # [layout.template, layout.unmarshalled_blocks]
            [layout.template, layout.template.send(:instance_variable_get, :"@parent_blocks")]
          else
            layout.template
          end
        end

        def find_blocks(node, blocks={})
          # puts "** find_blocks #{node.class.inspect} / #{blocks.keys.inspect}"
          if node.respond_to?(:nodelist) && node.nodelist
            # puts "  ==> find_blocks nodelist = #{node.nodelist.inspect}"
            node.nodelist.inject(blocks) do |b, node|
              if node.is_a?(Locomotive::Liquid::Tags::Block)
                b[node.name] = node
              end
              # else
              find_blocks(node, b) # FIXME: add nested blocks
              # end

              b
            end
          end

          blocks
        end

        def is_extending?(template)
          template.root.nodelist.any? { |node| node.is_a?(Extends) }
        end

      end

      ::Liquid::Template.register_tag('extends', Extends)
    end
  end
end