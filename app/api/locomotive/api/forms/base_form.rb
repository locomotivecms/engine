module Locomotive
  module API
    module Forms
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
          # changed.
          def attrs(*args)
            options = args.last.is_a?(Hash) ? args.pop : { localized: false }

            @attributes ||= []

            args.each do |name|
              @attributes << define_attribute(name, options[:localized])

              if options[:localized]
                @attributes << define_attribute(:"#{name}_translations")
              end
            end
          end

          def define_attribute(name, localized = false)
            # activemodel
            define_attribute_method(name)

            # getter
            self.send(:attr_reader, name)

            # setter
            define_method(:"#{name}=") do |val|
              if localized && val.is_a?(Hash)
                self.send(:"#{name}_translations=", val)
              else
                set_attribute(name, val)
              end
            end
          end

        end

        # @override - only return set attributes
        def serializable_hash
          changed.sort_by do |name|
            self.class.attributes.index(:"#{name}=")
          end.inject({}) do |hash, attribute|
            hash.merge({ attribute => send(attribute) })
          end.to_h.with_indifferent_access
        end

        def persisted?
          false
        end

        def set_attribute(name, value)
          send("#{name}_will_change!") unless send(name) == value
          instance_variable_set("@#{name}", value)
        end

      end

    end
  end
end
