module Locomotive
  module Liquid
    module Filters
      module Date

        def localized_date(input, *args)
          format, locale = args[0], args[1] rescue 'en'

          date = input.is_a?(String) ? Time.parse(input) : input

          if format.to_s.empty?
            return input.to_s
          end

          date = input.is_a?(String) ? Time.parse(input) : input

          if date.respond_to?(:strftime)
            I18n.locale = locale
            I18n.l date, :format => format
          else
            input
          end
        end

      end

      ::Liquid::Template.register_filter(Date)
    end
  end
end
