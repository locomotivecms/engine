module Locomotive

  module Mongoid

    module Document

      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps
        include ::Mongoid::CustomFields
      end

    end

  end

end
