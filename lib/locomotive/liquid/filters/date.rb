module Locomotive
  module Liquid
    module Filters
      module Date

        def localized_date(input, *args)
          return '' if input.blank?

          format, locale = args

          locale ||= I18n.locale
          format ||= I18n.t('date.formats.default', :locale => locale)

          if input.is_a?(String)
            begin
              fragments = ::Date._strptime(input, format)
              input = ::Date.new(fragments[:year], fragments[:mon], fragments[:mday])
            rescue
              input = Time.parse(input)
            end
          end

          return input.to_s unless input.respond_to?(:strftime)

          I18n.l input, :format => format, :locale => locale
        end

        alias :format_date :localized_date

      end

      ::Liquid::Template.register_filter(Date)
    end
  end
end
