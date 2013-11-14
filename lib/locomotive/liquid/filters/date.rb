module Locomotive
  module Liquid
    module Filters
      module Date

        def parse_date_time(input, format = nil)
          return '' if input.blank?

          format    ||= I18n.t('time.formats.default')
          date_time = ::DateTime._strptime(input, format)

          if date_time
            ::Time.zone.local(date_time[:year], date_time[:mon], date_time[:mday], date_time[:hour], date_time[:min], date_time[:sec] || 0)
          else
            ::Time.zone.parse(input) rescue ''
          end
        end

        def parse_date(input, format)
          return '' if input.blank?

          format  ||= I18n.t('date.formats.default')
          date    = ::Date._strptime(input, format)

          if date
            ::Date.new(date[:year], date[:mon], date[:mday])
          else
            ::Date.parse(value) rescue ''
          end
        end

        def distance_of_time_in_words(input, from_time = Time.zone.now, include_seconds = false)
          # make sure we deals with instances of Time
          input     = to_time(input)
          from_time = to_time(from_time)

          ::ActionController::Base.helpers.distance_of_time_in_words(input, from_time, { include_seconds: include_seconds })
        end

        def localized_date(input, *args)
          return '' if input.blank?

          format, locale = args

          locale ||= I18n.locale
          format ||= I18n.t('date.formats.default', locale: locale)

          if input.is_a?(String)
            begin
              fragments = ::Date._strptime(input, format)
              input = ::Date.new(fragments[:year], fragments[:mon], fragments[:mday])
            rescue
              input = Time.parse(input)
            end
          end

          return input.to_s unless input.respond_to?(:strftime)

          input = input.in_time_zone(@context.registers[:site].timezone) if input.respond_to?(:in_time_zone)

          I18n.l input, format: format, locale: locale
        end

        alias :format_date :localized_date

        private

        def to_time(input)
          case input
          when Date   then input.to_time
          when String then Time.zone.parse(input)
          else
            input
          end
        end

      end

      ::Liquid::Template.register_filter(Date)
    end
  end
end
