module Locomotive

  module Mongoid

    module Document

      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps
        include ::Mongoid::CustomFields
      end

      # def to_json
      #
      # end

      def as_json(options={})
        attrs = super(options)
        attrs["id"] = attrs["_id"]
        attrs
      end

    end

  end

end
