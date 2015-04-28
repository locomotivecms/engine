module Locomotive
  module API
    module Entities

      class ContentEntryEntity < BaseEntity

        # expose

        expose :_slug
        expose :_label
        expose :_position
        expose :_visible

        expose :seo_title, :meta_keywords, :meta_description

        expose :content_type_slug


        # default attributes
        #  -- _content_type_id
        #     _position
        #     _visible
        #     _seo_title

      end

    end
  end
end
