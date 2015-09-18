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

        end

      end
    end
  end
end
