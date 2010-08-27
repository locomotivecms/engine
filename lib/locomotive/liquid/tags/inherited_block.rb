module Locomotive
  module Liquid
    module Tags
      class InheritedBlock < ::Liquid::InheritedBlock

        def initialize(tag_name, markup, tokens, context)
          if markup =~ Syntax
            @name = $1
          else
            raise SyntaxError.new("Error in tag 'block' - Valid syntax: block [name]")
          end

          context[:current_block] = self # for now, no need to push it in a stack

          puts "** InheritedBlock[begin] #{context.object_id} / #{@name} / #{context[:page].try(:fullpath)}"

          super if tokens
        end

        def end_tag
          puts "** InheritedBlock[end_tag] before super #{@name} / #{@context.object_id}/ #{@context[:page].fullpath}"

          self.register_current_block

          if !self.contains_super?(@nodelist) # then disable all editable_elements coming from the parent block too and not used
            puts "** InheritedBlock[end_tag] disabling_parent_editable_elements... #{@context.object_id}"
            @context[:page].disable_parent_editable_elements(@name)
          end

          puts "** InheritedBlock[end_tag] after super #{@name} / #{@context.object_id}/ #{@context[:page].fullpath}"
        end

        protected

        def register_current_block
          @context[:blocks] ||= {}

          block = @context[:blocks][@name]

          if block
            # needed for the block.super statement
            # puts "[BLOCK #{@name}|end_tag] nodelist #{@nodelist.inspect}"
            block.add_parent(@nodelist)

            @parent = block.parent
            @nodelist = block.nodelist

            # puts "[BLOCK #{@name}|end_tag] direct parent #{block.parent.inspect}"
          else
            # register it
            # puts "[BLOCK #{@name}|end_tag] register it"
            @context[:blocks][@name] = self
          end
        end

        def contains_super?(nodelist)
          nodelist.any? do |node|
            if node.is_a?(String) && node =~ /\{\{\s*block.super\s*\}\}/
              true
            elsif node.respond_to?(:nodelist) && !node.is_a?(Locomotive::Liquid::Tags::InheritedBlock)
              contains_super?(node.nodelist)
            end
          end
        end

      end

      ::Liquid::Template.register_tag('block', InheritedBlock)
    end
  end
end