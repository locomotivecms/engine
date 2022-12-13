module Locomotive
  module Concerns
    module Shared
      module Seo
        extend ActiveSupport::Concern

        included do
          field :seo_title,         type: String, localize: true
          field :meta_keywords,     type: String, localize: true
          field :meta_description,  type: String, localize: true
          field :meta_robots,       type: String, localize: true
        end

      end # Seo
    end # Shared
  end # Concerns
end # Locomotive
