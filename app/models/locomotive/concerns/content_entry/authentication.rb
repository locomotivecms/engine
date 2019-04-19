module Locomotive
  module Concerns
    module ContentEntry
      module Authentication

        def with_authentication?
          self.content_type.entries_custom_fields.where(type: 'password').count > 0
        end

      end
    end
  end
end
