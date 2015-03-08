module Locomotive
  class SnippetEntity < BaseEntity
    expose :name, :slug, :template

    with_options(format_with: :short_date) do
      expose :updated_at
    end
  end
end
