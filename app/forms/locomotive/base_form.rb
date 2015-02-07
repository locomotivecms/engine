module Locomotive
  class BaseForm
    include ActiveModel::Model
    include ActiveModel::Serialization

    attr_accessor :persisted

    delegate :save, to: :model_object

    attr_writer :model_object

    class << self
      def attributes
        @attributes
      end

      def attrs(*args)
        @attributes = [@attributes, *args].uniq.compact
        self.send(:attr_accessor, *@attributes)
      end

      def existing(model_object)
        existing = new
        existing.persisted = true
        existing.model_object = model_object
        existing
      end
    end

    def model_object
      @model_object ||= model.new(serializable_hash)
    end

    def persisted?
      !!persisted
    end

    def update(*args)
      return false unless persisted?
      model_object.update(*args)
      model_object
    end

    def attributes
      self.class.attributes.inject({}) do |hash, attribute|
        hash.merge(attribute => send(attribute))
      end
    end

    private

    def model
      self.class.name.gsub(/Form/, '').constantize
    end
  end
end
