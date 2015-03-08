module Locomotive
  class BaseEntity < Grape::Entity
    include ActionView::Helpers::NumberHelper

    format_with(:human_size) { |number| number_to_human_size(number) }
    format_with(:short_date) { |date| I18n.l(date, format: :short) }
    format_with(:labelize) { |label| label.gsub(/[\"\']/, '').gsub('-', ' ').humanize }

  end
end
