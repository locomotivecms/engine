module Locomotive
  module Concerns
    module Page
      module Listed

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :listed, type: Boolean, default: true

        end

      end
    end
  end
end
