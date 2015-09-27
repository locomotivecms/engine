module Locomotive
  module Concerns
    module Site
      module Cache

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :cache_enabled,     type: Boolean, default: false
          field :template_version,  type: DateTime
          field :content_version,   type: DateTime

          ## callbacks ##
          before_save  :touch_content_version

          def touch_content_version
            touch(:content_version)
            true
          end

        end

        def last_modified_at
          [self.content_version, self.template_version].compact.sort.last || self.updated_at
        end

      end
    end
  end
end
