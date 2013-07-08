module Locomotive
  module Extensions
    module ContentEntry
      module Csv

        extend ActiveSupport::Concern

        # Get the values from the custom fields as an array.
        # Values are ordered by the position of the custom fields.
        # It also adds the created_at value of the instance.
        #
        # @param [ Hash ] options For now, stores only the host for the File fields.
        #
        # @return [ Array ]
        #
        def to_values(options = {})
          values = self.content_type.ordered_entries_custom_fields.map do |field|
            value = self.send(field.name)
            self.value_from_type(field.type.to_sym, value, options)
          end.compact

          values << I18n.l(self.created_at, format: :long)
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
            labels = fields.map(&:label) << I18n.t('mongoid.attributes.locomotive/content_entry.created_at')

            CSV.generate(csv_options) do |csv|
              # header
              csv << labels
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