module Locomotive
  module API
    module Forms

      class ThemeAssetForm < BaseForm

        attrs :source, :plain_text_name, :local_path, :content_type, :folder,
              :plain_text_type, :performing_plain_text

      end

    end
  end
end
