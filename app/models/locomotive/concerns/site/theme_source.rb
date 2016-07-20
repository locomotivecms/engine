module Locomotive
  module Concerns
    module Site
      module ThemeSource

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :is_theme,          type: Boolean,  default: false
          field :theme_name,        type: String,   default: ''

          scope :themes, -> { where(is_theme: true) }

        end

      end
    end
  end
end
