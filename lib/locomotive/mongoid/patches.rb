# encoding: utf-8

require 'mongoid'

class RawArray < ::Array
  def resizable?; false; end
end

# FIXME: we have serialiez templates which have references to the old BSON::ObjectId class.
module BSON
  class ObjectId < Moped::BSON::ObjectId; end
end

module Mongoid#:nodoc:

  module Document #:nodoc:
    def as_json(options = {})
      attrs = super(options)
      attrs["id"] = attrs["_id"]
      attrs
    end
  end

  class Criteria
    def without_sorting
      clone.tap { |crit| crit.options.delete(:sort) }
    end

    # http://code.dblock.org/paging-and-iterating-over-large-mongo-collections
    def each_by(by, &block)
      idx = total = 0
      set_limit = options[:limit]
      while ((results = ordered_clone.limit(by).skip(idx)) && results.any?)
        results.each do |result|
          return self if set_limit and set_limit >= total
          total += 1
          yield result
        end
        idx += by
      end
      self
    end

    # Optimized version of the max aggregate method.
    # It works efficiently only if the field is part of a MongoDB index.
    # more here: http://stackoverflow.com/questions/4762980/getting-the-highest-value-of-a-column-in-mongodb
    def indexed_max(field)
      _criteria = criteria.order_by(field.to_sym.desc).only(field.to_sym)
      selector  = _criteria.send(:selector_with_type_selection)
      fields    = _criteria.options[:fields]
      sort      = _criteria.options[:sort]

      document = collection.find(selector).select(fields).sort(sort).limit(1).first
      document ? document[field.to_s].to_i : nil
    end

    def to_liquid
      Locomotive::Liquid::Drops::ProxyCollection.new(self)
    end

    private

    def ordered_clone
      options[:sort] ? clone : clone.asc(:_id)
    end
  end

  module Finders
    def indexed_max(field)
      with_default_scope.indexed_max(field)
    end
  end

  module Criterion
    class Selector < Hash
      # for some reason, the store method behaves differently than the []= one, causing regression bugs (query not localized)
      alias :store :[]=
    end
  end

  # without callback feature
  module Callbacks #:nodoc:
    module ClassMethods #:nodoc:
      def without_callback(*args, &block)
        skip_callback(*args)
        yield
        set_callback(*args)
      end
    end
  end

  # make the validators work with localized field
  module Validations #:nodoc:

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
