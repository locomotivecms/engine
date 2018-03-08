module Locomotive
  module Concerns
    module Shared
      module Userstamp
        extend ActiveSupport::Concern

        included do
          belongs_to :created_by, class_name: 'Locomotive::Account', optional: true
          belongs_to :updated_by, class_name: 'Locomotive::Account', optional: true
        end

      end # Userstamp
    end # Shared
  end # Extensions
end # Locomotive
