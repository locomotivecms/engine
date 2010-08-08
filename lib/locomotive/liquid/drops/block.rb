module Locomotive
  module Liquid
    module Drops
      class Block < ::Liquid::Drop

        def initialize(block)
          @block = block
        end

        def super
          @block.call_super(@context)
        end
      end
    end
  end
end