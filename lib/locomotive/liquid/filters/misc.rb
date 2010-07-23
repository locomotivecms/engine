module Locomotive
  module Liquid
    module Filters
      module Misc

        def underscore(input)
          input.to_s.gsub(' ', '_').gsub('/', '_').underscore
        end

        def dasherize(input)
          input.to_s.gsub(' ', '-').gsub('/', '-').dasherize
        end

        def concat(input, *args)
          result = input.to_s
          args.flatten.each { |a| result << a.to_s }
          result
        end

        def modulo(word, index, modulo)
          (index.to_i + 1) % modulo == 0 ? word : ''
        end

      end

      ::Liquid::Template.register_filter(Misc)

    end
  end
end
