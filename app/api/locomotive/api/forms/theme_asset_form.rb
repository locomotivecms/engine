module Locomotive
  module API
    module Forms

      class ThemeAssetForm < BaseForm

        attrs :source, :folder, :performing_plain_text

        def performing_plain_text
          false
        end

      end

    end
  end
end
