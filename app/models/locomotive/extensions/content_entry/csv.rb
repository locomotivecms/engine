module Locomotive
  module Extensions
    module ContentEntry
      module Csv

        extend ActiveSupport::Concern

        # Get the values from the custom fields as an array.
        # Values are ordered by the position of the custom fields.
        #
        # @param [ Hash ] options For now, stores only the host for the File fields.
        #
        # @return [ Array ]
        #
        def to_values(options = {})
          self.content_type.ordered_entries_custom_fields.map do |field|
            value = self.send(field.name)
            self.value_from_type(field.type.to_sym, value, options)
          end.compact
        end

        protected

        # Return the transformed value for a particular field type (string, text, ...etc).
        #
        # @param [ Symbol ] type Type of the field
        # @param [ Object ] value Value of the field in the current instance
        # @param [ Hash ] options For now, stores only the host for the File fields.
        #
        # @return [ Object ]
        #
        def value_from_type(type, value, options)
          case type
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
              csv << (fields.map(&:label) + [I18n.t('mongoid.attributes.locomotive/content_entry.created_at')])
              # body
              all.each do |entry|
                csv << (entry.to_values(options) + [I18n.l(entry.created_at, format: :long)])
              end
            end
          end

        end

      end
    end
  end
end