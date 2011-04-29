module Extensions
  module Shared
    module Seo
      extend ActiveSupport::Concern

      included do
        field :meta_keywords, :type => String
        field :meta_description, :type => String
      end
      
    end # Seo
  end # Shared
end # Extensions
