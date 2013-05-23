module Locomotive
  module Liquid
    module Tags
      class Hybrid < ::Liquid::Block
        def parse(tokens)
          nesting = 0
          tokens.each do |token|
            next unless token =~ IsTag
            if token =~ FullToken
              if nesting == 0 && $1 == block_delimiter
                @render_as_block = true
                super
                return
              elsif $1 == block_name
                nesting += 1
              elsif $1 == block_delimiter
                nesting -= 1
              end
            end
          end
        end
      end
    end
  end
end