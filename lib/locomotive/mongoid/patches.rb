# encoding: utf-8

require 'mongoid'

class RawArray < ::Array
  def resizable?; false; end
end

# FIXME: we have serialized templates which have references to the old BSON::ObjectId class.
module Moped
  module BSON
    class ObjectId < ::BSON::ObjectId; end
  end
end
# BSON::ObjectId

module Mongoid #:nodoc:

  # FIXME: https://github.com/benedikt/mongoid-tree/issues/58
  # We replace all the @_#{name} occurences by @_#{name}_ivar.
  module Relations
    module Accessors
      def reset_relation_criteria(name)
        if instance_variable_defined?("@_#{name}_ivar")
          send(name).reset_unloaded
        end
      end
      def set_relation(name, relation)
        instance_variable_set("@_#{name}_ivar", relation)
      end
    end
    def reload_relations
      relations.each_pair do |name, meta|
        if instance_variable_defined?("@_#{name}_ivar")
          if _parent.nil? || instance_variable_get("@_#{name}_ivar") != _parent
            remove_instance_variable("@_#{name}_ivar")
          end
        end
      end
    end
  end
  module Extensions
    module Object
      def ivar(name)
        if instance_variable_defined?("@_#{name}_ivar")
          return instance_variable_get("@_#{name}_ivar")
        else
          false
        end
      end
      def remove_ivar(name)
        if instance_variable_defined?("@_#{name}_ivar")
          return remove_instance_variable("@_#{name}_ivar")
        else
          false
        end
      end
    end
  end

  module Document #:nodoc:
    def as_json(options = {})
      attrs = super(options)
      attrs["id"] = attrs["_id"]
      attrs
    end
  end

  class Criteria
    def to_liquid
      Locomotive::Liquid::Drops::ProxyCollection.new(self)
    end
  end

  module Criterion
    class Selector < Hash
      # for some reason, the store method behaves differently than the []= one, causing regression bugs (query not localized)
      alias :store :[]=
    end
  end

  # without callback feature
  # module Callbacks #:nodoc:
  #   module ClassMethods #:nodoc:
  #     def without_callback(*args, &block)
  #       skip_callback(*args)
  #       yield
  #       set_callback(*args)
  #     end
  #   end
  # end

  # make the validators work with localized field
  module Validatable #:nodoc:

    class ExclusionValidator < ActiveModel::Validations::ExclusionValidator
      include Localizable
    end

    module ClassMethods
      def validates_exclusion_of(*args)
        validates_with(ExclusionValidator, _merge_attributes(args))
      end
    end

    module LocalizedEachValidator

      # Performs validation on the supplied record. By default this will call
      # +validates_each+ to determine validity therefore subclasses should
      # override +validates_each+ with validation logic.
      def validate(record)
        attributes.each do |attribute|
          field = record.fields[attribute.to_s]

          # make sure that we use the localized value and not the translations when we test the allow_nil and allow_blank options
          value = field.try(:localized?) ? record.send(attribute.to_sym) : record.read_attribute_for_validation(attribute)

          next if (value.nil? && options[:allow_nil]) || (value.blank? && options[:allow_blank])

          # use the translations of the localized field for the next part
          value = record.read_attribute_for_validation(attribute) if field.try(:localized?)

          validate_each(record, attribute, value)
        end
      end

    end

    [FormatValidator, LengthValidator, PresenceValidator, UniquenessValidator, ExclusionValidator].each do |klass|
      klass.send(:include, LocalizedEachValidator)
    end

  end

end
