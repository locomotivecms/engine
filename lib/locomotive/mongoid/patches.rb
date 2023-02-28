# # encoding: utf-8

require 'mongoid'

class RawArray < ::Array
  def resizable?; false; end
end

module BSON
  class ObjectId
    def to_json(*)
      to_s.to_json
    end
    def as_json(*)
      to_s.as_json
    end
  end
end

module Mongoid #:nodoc:

  # FIXME: the Origin (used by Steam) and Mongoid gems both modify the Symbol class
  # to allow writing queries like .where(:position.lt => 1)
  # By convention, Origin::Key will be the one. So we need to make sure it doesn't
  # break the Mongoid queries.
  class Criteria
    module Queryable
      module Selectable
        def selection(criterion = nil)
          clone.tap do |query|
            if criterion
              criterion.each_pair do |field, value|
                _field = field.is_a?(Key) || field.is_a?(Origin::Key) ? field : field.to_s
                yield(query.selector, _field, value)
              end
            end
            query.reset_strategies!
          end
        end
      end
    end
  end

  # Hack to give a specific type to the EditableElement
  module Association
    module Embedded
      class EmbedsMany
        class Proxy < Association::Many
          def with_same_class!(document, klass)
            return document if document.is_a?(klass)

            Factory.build(klass, {}).tap do |_document|
              # make it part of the relationship
              _document.apply_post_processed_defaults
              integrate(_document)

              # make it look like the old document
              attributes = document.attributes
              attributes['_type'] = _document._type

              _document.instance_variable_set(:@attributes, attributes)
              _document.new_record  = document.new_record?
              _document._index      = document._index

              # finally, make the change in the lists
              _target[_document._index]   = _document
              _unscoped[_document._index] = _document
            end
          end
        end
      end
    end
  end

#   # FIXME: https://github.com/benedikt/mongoid-tree/issues/58
#   # We replace all the @_#{name} occurences by @_#{name}_ivar.
#   # module Association
#   #   module Accessors
#   #     def reset_relation_criteria(name)
#   #       if instance_variable_defined?("@_#{name}_ivar")
#   #         send(name).reset_unloaded
#   #       end
#   #     end
#   #     def set_relation(name, relation)
#   #       instance_variable_set("@_#{name}_ivar", relation)
#   #     end
#   #   end
#   #   def reload_relations
#   #     relations.each_pair do |name, meta|
#   #       if instance_variable_defined?("@_#{name}_ivar")
#   #         if _parent.nil? || instance_variable_get("@_#{name}_ivar") != _parent
#   #           remove_instance_variable("@_#{name}_ivar")
#   #         end
#   #       end
#   #     end
#   #   end

#   #   module Embedded
#   #     class Many < Relations::Many

#   #       def with_same_class!(document, klass)
#   #         return document if document.is_a?(klass)

#   #         Factory.build(klass, {}).tap do |_document|
#   #           # make it part of the relationship
#   #           _document.apply_post_processed_defaults
#   #           integrate(_document)

#   #           # make it look like the old document
#   #           attributes = document.attributes
#   #           attributes['_type'] = _document._type

#   #           _document.instance_variable_set(:@attributes, attributes)
#   #           _document.new_record  = document.new_record?
#   #           _document._index      = document._index

#   #           # finally, make the change in the lists
#   #           target[_document._index]    = _document
#   #           _unscoped[_document._index] = _document
#   #         end
#   #       end

#   #     end
#   #   end

#   # end

  # module Extensions
  #   module Object
  #     def ivar(name)
  #       if instance_variable_defined?("@_#{name}_ivar")
  #         return instance_variable_get("@_#{name}_ivar")
  #       else
  #         false
  #       end
  #     end
  #     def remove_ivar(name)
  #       if instance_variable_defined?("@_#{name}_ivar")
  #         return remove_instance_variable("@_#{name}_ivar")
  #       else
  #         false
  #       end
  #     end
  #   end
  # end

  module Document #:nodoc:
    def as_json(options = {})
      attrs = super(options)
      attrs['id'] = attrs['_id']
      attrs
    end
  end

  class Criteria
    def first!
      self.first.tap do |model|
        if model.nil?
          raise Mongoid::Errors::DocumentNotFound.new(self.klass, self.selector)
        end
      end
    end

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

      document = collection.find(selector).projection(fields).sort(sort).limit(1).first
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

  module Findable
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

      def validate_each(document, attribute, value)
        # validate the value only in the current locale
        if (field = document.fields[document.database_field_name(attribute)]).try(:localized?)
          value = value.try(:slice, ::Mongoid::Fields::I18n.locale.to_s)
        end

        super(document, attribute, value)
      end

    end

    [FormatValidator, LengthValidator, UniquenessValidator, ExclusionValidator].each do |klass|
      klass.send(:include, LocalizedEachValidator)
    end

    # PresenceValidator defines its own validate_each method
    PresenceValidator.send(:prepend, LocalizedEachValidator)
  end

end
