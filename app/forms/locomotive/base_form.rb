module Locomotive

  class BaseForm
    include ActiveModel::Model
    include ActiveModel::Serialization
    include ActiveModel::Dirty


    attr_accessor :_persisted, :_policy

    class << self
      def attributes
        @attributes
      end

      # Set up accessor methods, and define setters to notify Dirty that they've
      #  changed.
      def attrs(*args)
        self.define_attribute_methods(*args)
        @attributes = [attributes, *args].uniq.compact
        @attributes.each do |attribute|
          define_method("#{attribute}=") do |val|
            send("#{attribute}_will_change!") unless send(attribute) == val
            instance_variable_set("@#{attribute}", val)
          end
        end
        self.send(:attr_reader, *@attributes)
      end

    end

    # @override - only return set attributes
    def serializable_hash
      changed.inject({}) do |hash, attribute|
        hash.merge({ attribute => send(attribute) })
      end.with_indifferent_access
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
