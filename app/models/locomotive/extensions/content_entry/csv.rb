module Locomotive
  module Extensions
    module ContentEntry
      module Csv

        extend ActiveSupport::Concern

        # get the values from the custom fields as an array.
        # Values are ordered by the position of the custom fields.
        #
        # @param [ Hash ] options For now, stores only the host for the File fields.
        #
        # @return [ Array ]
        #
        def to_values(options = {})
          self.content_type.ordered_entries_custom_fields.map do |field|
            value = self.send(field.name)
            case field.type.to_sym
            when :file
              value.blank? ? '' : value.guess_url(options[:host])
            when :belongs_to
              value.try(:_label)
            when :has_many, :many_to_many
              value.map(&:_label).join(', ')
            when :tags
              [*value].join(', ')
            else
              value
            end
          end.compact
        end

        module ClassMethods

          # Generate a csv from a collection of content entries
          #
          # @param [ Hash ] options Options for the csv generation
          #
          # @return [ String ] The well-generated CSV document
          #
          def to_csv(options = {})
            content_type  = options.delete(:content_type) || all.first.try(:content_type)
            csv_options   = options.select do |k, v|
              CSV::DEFAULT_OPTIONS.keys.include?(k.to_sym)
            end

            fields = content_type.ordered_entries_custom_fields

            CSV.generate(csv_options) do |csv|
              # header
              csv << fields.map(&:label)
              # body
              all.each do |entry|
                csv << entry.to_values(options)
              end
            end
          end

        end

      end
    end
  end
end