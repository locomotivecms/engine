module Locomotive
  module Liquid
    module Filters
      module Date

        def localized_date(input, *args)
          format, locale = args[0], args[1] || 'en'

          return input.to_s if format.to_s.empty?

          if input.is_a?(String)
            fragments = ::Date._strptime(input, I18n.t('date.formats.default'))
            date = ::Date.new(fragments[:year], fragments[:mon], fragments[:mday])
          else
            date = input
          end

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
