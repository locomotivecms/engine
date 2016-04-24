module Locomotive
  module Concerns
    module ContentType
      module FilterFields

        extend ActiveSupport::Concern

        included do
          ## fields ##
          field :filter_fields, type: Array

          ## callbacks ##
          before_validation :sanitize_filter_fields
        end

        # We do not want to have a blank value in the list of fields used to filter the entries.
        def sanitize_filter_fields
          if self.filter_fields
            self.filter_fields.reject! { |id| id.blank? }
          end
        end

      end
    end
  end
end
