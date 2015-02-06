module Locomotive
  class BaseForm
    include ActiveModel::Model
    include ActiveModel::Serialization

    delegate :save, to: :model_object

    def self.attrs(*args)
      @attributes = args
      self.send(:attr_accessor, *args)
    end

    def self.attributes
      @attributes || {}
    end

    def attributes
      self.class.attributes.inject({}) do |hash, attribute|
        hash.merge(attribute => send(attribute))
      end

    end

    private

    def model_object
      @model_object ||= model.new(self.serializable_hash)
    end

    def model
      self.class.name.gsub(/Form/, '').constantize
    end
  end
end
