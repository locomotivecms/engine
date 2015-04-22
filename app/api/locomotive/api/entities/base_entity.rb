module Locomotive
  module API
    module Entities

      class BaseEntity < ::Grape::Entity

        include ActionView::Helpers::NumberHelper
        include ActionView::Helpers::TextHelper

        format_with(:human_size) { |number| number_to_human_size(number) }
        format_with(:iso_timestamp) { |date_time| date_time.try(:iso8601) }
        format_with(:labelize) { |label| label.gsub(/[\"\']/, '').gsub('-', ' ').humanize }
        format_with(:truncate_to_3) { |target| truncate(target, length: 3) }

        expose :_id do |entity, _|
          entity._id.to_s
        end

        expose :created_at, format_with: :iso_timestamp
        expose :updated_at, format_with: :iso_timestamp

      end

    end
  end
end
