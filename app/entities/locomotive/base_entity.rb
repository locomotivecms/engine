module Locomotive
  class BaseEntity < ::Grape::Entity

    include ActionView::Helpers::NumberHelper

    format_with(:human_size) { |number| number_to_human_size(number) }
    format_with(:iso_timestamp) { |date_time| date_time.try(:iso8601) }
    format_with(:labelize) { |label| label.gsub(/[\"\']/, '').gsub('-', ' ').humanize }

    expose :_id do |entity, _|
      entity._id.to_s
    end

    expose :created_at, format_with: :iso_timestamp
    expose :updated_at, format_with: :iso_timestamp

  end
end
