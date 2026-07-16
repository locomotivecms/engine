# # encoding: utf-8

require 'mongoid'

class RawArray < ::Array
  def resizable?; false; end
end

module Mongoid #:nodoc:

  module Fields
    module ClassMethods
      alias_method :add_field_without_locomotive_patch, :add_field

      def add_field(name, options = {})
        # FIXME: The Rails ActionView inputs get the value of a field from the <FIELD>_before_type_cast method if it exists.
        # In Mongoid 7, the Mongoid core team implemented the `_before_type_cast?` / `_before_type_cast`
        # for ALL the fields including the localized ones.
        # Incidentally, it breaks the form inputs for localized fields.
        # This patch restores the old behavior for localized fiels by implementing the X_came_from_user? method
        # which makes the form inputs use the translated value of a field.
        generated_methods.module_eval do
          re_define_method("#{name}_came_from_user?") do
            false
          end
        end if options[:localize]

        add_field_without_locomotive_patch(name, options)
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

  module Document #:nodoc:
    def as_json(options = {})
      attrs = super(options)
      attrs['id'] = attrs['_id']
      attrs
    end
  end

  class Criteria
    def to_liquid
      Locomotive::Liquid::Drops::ProxyCollection.new(self)
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
