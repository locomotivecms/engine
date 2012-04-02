module Locomotive
  module Liquid
    module Filters
      module Text

        def underscore(input)
          input.to_s.gsub(' ', '_').gsub('/', '_').underscore
        end

        def dasherize(input)
          input.to_s.gsub(' ', '-').gsub('/', '-').dasherize
        end

        def multi_line(input)
          input.to_s.gsub("\n", '<br/>')
        end

        def concat(input, *args)
          result = input.to_s
          args.flatten.each { |a| result << a.to_s }
          result
        end

        def textile(input)
          ::RedCloth.new(input).to_html
        end

      end

      ::Liquid::Template.register_filter(Text)

    end
  end
end
