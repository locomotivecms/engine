module Locomotive
  module API
    module Forms

      class SnippetForm < BaseForm

        attrs :name, :slug
        attrs :template, localized: true

      end

    end
  end
end
