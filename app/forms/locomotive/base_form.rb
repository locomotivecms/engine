module Locomotive
 
  class BaseForm
    include ActiveModel::Model
    include ActiveModel::Serialization

    attr_accessor :_persisted, :_policy

    class << self
      def attributes
        @attributes
      end

      def attrs(*args)
        @attributes = [@attributes, *args].uniq.compact
        self.send(:attr_accessor, *@attributes)
      end

    end

    def persisted?
      false
    end

    def attributes
      self.class.attributes.inject({}) do |hash, attribute|
        hash.merge(attribute => send(attribute))
      end
    end

  end
end
