module Locomotive
  module Presentable

    extend ActiveSupport::Concern

    included do

      # callbacks enabled
      include ActiveSupport::Callbacks
      define_callbacks :set_attributes

      # keep tracks of the getters and setters
      class << self; attr_accessor :getters, :setters, :property_options end

      # __source is a reference to the main object (__ is for variable protection)
      attr_reader :__source, :__options

    end

    # Initializer
    def initialize(object, options = {})
      @__source   = object
      @__options  = options || {}

      self.after_initialize
    end

    # Method called just after a presenter has been
    # initialized. This method can be overridden.
    #
    def after_initialize
      # do nothing
    end

    # Set the attributes of the presenter. Only call the methods
    # which the presenter can handle.
    #
    # @param [ Hash ] value The attributes
    #
    def attributes=(values)
      return unless values

      @_attributes = values # memoize them for the callbacks

      run_callbacks :set_attributes do
        _values = values.stringify_keys

        self.setters.each do |name|
          if _values.has_key?(name)
            _options = self.property_options[name] || {}

            if _options[:if].blank? || self.instance_eval(&_options[:if])
              self.send(:"#{name}=", _values[name])
            end
          end
        end
      end
    end

    # Build the hash of the values of all the properties.
    #
    # @param [ Array ] methods (Optional) List of methods instead of using the default getters
    #
    # @return [ Hash ] The "attributes" of the object
    #
    def as_json(methods = nil)
      methods ||= self.getters
      {}.tap do |hash|
        methods.each do |meth|
          _options = self.property_options[meth]

          if _options[:if].blank? || self.instance_eval(&_options[:if])
            value = self.send(meth.to_sym)

            if !value.nil? || (_options && !!_options[:allow_nil])
              hash[meth] = value
            end
          end
        end
      end
    end

    # Return the list of getters.
    #
    # @return [ List ] Array of method names
    #
    def getters
      self.class.getters || []
    end

    # Return the list of setters.
    #
    # @return [ List ] Array of method names
    #
    def setters
      self.class.setters || []
    end

    def property_options
      self.class.property_options || {}
    end

    module ClassMethods

      # Override inherited in order to copy the parent list
      # of getters, setters and property options.
      #
      # @param [ Class ] subclass The subclass inheriting from the current class
      #
      def inherited(subclass)
        subclass.getters = getters.clone if getters
        subclass.setters = setters.clone if setters
        subclass.property_options = property_options.clone if property_options

        super
      end

      # Add multiple properties all in once.
      # If th last property name is a hash, then it will be
      # used as the options for all the other properties.
      #
      # @param [ Array ] args List of property names
      #
      def properties(*names)
        options = names.last.is_a?(Hash) ? names.pop : {}

        names.each do |name|
          property(name, options)
        end
      end

      # Add a property to the current instance. It creates getter/setter methods
      # related to that property. By default, the getter and setter are bound
      # to the source object.
      #
      # @param [ String ] name The name of the property
      # @param [ Hash ] options The options related to the property.
      #
      def property(name, options = {})
        aliases     = [*options[:alias]]
        collection  = options[:collection] == true

        (@property_options ||= {})[name.to_s] = options

        unless options[:only_setter] == true
          define_getter(name, collection)
        end

        unless options[:only_getter] == true
          define_setter(name, aliases)
        end
      end

      # Add a collection to the current instance. It creates getter/setter
      # mapped to the collection of the source object.
      #
      # @param [ String ] name The name of the collection
      # @param [ Hash ] options The options related to the collection (:alias)
      #
      def collection(name, options = {})
        property(name, options.merge(collection: true, type: 'Array'))
      end

      def define_getter(name, collection = false)
        (@getters ||= []) << name.to_s

        class_eval <<-EOV
          def #{name}
            if #{collection.to_s}
              list = self.__source.send(:#{name})
              list ? list.map(&:as_json) : []
            else
              self.__source.send(:#{name})
            end
          end
        EOV
      end

      def define_setter(name, aliases = [])
        (@setters ||= []) << name.to_s
        @setters += aliases.map(&:to_s)

        class_eval <<-EOV
          def #{name}=(value)
            self.__source.send(:#{name}=, value)
          end
        EOV

        aliases.each do |_name|
          class_eval <<-EOV
            def #{_name}=(value)
              self.#{name} = value
            end
          EOV
        end
      end

      # Get the name of the property for which
      # the property passed in parameter is an alias.
      #
      # @param [ String ] alias_name Name of the alias
      #
      # @return [ String ] The original property
      #
      def alias_of(alias_name)
        self.setters.find do |name|
          list = [*(self.property_options[name] || {})[:alias]] || []
          list.include?(alias_name.to_sym)
        end
      end


    end # ClassMethods

  end # Presentable
end # Locomotive