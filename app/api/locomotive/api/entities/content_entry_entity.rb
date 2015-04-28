module Locomotive
  module API
    module Entities

      class ContentEntryEntity < BaseEntity

        expose :_slug, :content_type_slug

        expose :_label, :_position, :_visible

        expose :seo_title, :meta_keywords, :meta_description

      end

    end
  end
end
