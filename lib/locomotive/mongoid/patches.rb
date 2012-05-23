# encoding: utf-8

require 'mongoid'

module Mongoid#:nodoc:

  module Document #:nodoc:
    def as_json(options = {})
      attrs = super(options)
      attrs["id"] = attrs["_id"]
      attrs
    end
  end

  module Fields #:nodoc:
    module Internal #:nodoc:
      class RawArray < Mongoid::Fields::Internal::Array
        def resizable?; false; end
      end
    end

    class RawArray < ::Array; end
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
    def read_attribute_for_validation_with_localization(attr)
      if fields[attr.to_s] && fields[attr.to_s].localized?
        send(attr.to_sym)
      else
        read_attribute_for_validation_without_localization(attr)
      end
    end

    alias_method_chain :read_attribute_for_validation, :localization

    class PresenceValidator < ActiveModel::EachValidator
      def validate_each(document, attribute, value)
        document.errors.add(attribute, :blank, options) if value.blank?
      end
    end
  end

end
