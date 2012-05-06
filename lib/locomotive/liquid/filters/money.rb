module Locomotive
  module Liquid
    module Filters
      module Money
        include ActionView::Helpers::NumberHelper
        def localized_money(input, *args)

          return '' if input.blank?
          options = args_to_options(args)
          options[:locale] ||= I18n.locale
          options[:format] ||= I18n.t('number.currency.format.format', :locale => options[:locale])

          money = input.is_a?(::Money) ? input : ::Money.parse( input ) rescue ::Money.new( 0 )

          number_to_currency(money.to_d, options)
        end

        alias :format_money :localized_money

      end

      ::Liquid::Template.register_filter(Money)
    end
  end
end
