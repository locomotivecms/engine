module Locomotive
  module Concerns
    module Shared
      module JsonAttribute

        extend ActiveSupport::Concern

        module ClassMethods

          def json_attribute(name)
            validate { |record| record.send(:json_attribute_must_be_valid, name) }
            before_validation do |record| 
              record.send(:add_json_uncastable_values_error, name)
              record.send(:add_json_parsing_error, name)
            end

            define_method(:"#{name}=") do |json|
              super(decode_json(name, json))
            end
          end

        end

        private

        def decode_json(name, json)
          begin
            value = json.is_a?(String) ? ActiveSupport::JSON.decode(CGI.unescape(json)) : json
            instance_variable_set(:"@#{name}_json_parsing_error", nil)
            value
          rescue ActiveSupport::JSON.parse_error
            instance_variable_set(:"@#{name}_json_parsing_error", $!.message)
            nil
          end
        end

        def json_attribute_must_be_valid(name)
          json    = self.send(name)
          schema  = respond_to?(:"_#{name}_schema", true) ? self.send(:"_#{name}_schema") : {}

          return if json.blank?

          begin
            JSON::Validator.validate!(schema, json)
          rescue JSON::Schema::ValidationError
            self.errors.add(name, $!.message)
          end
        end

        def add_json_uncastable_values_error(name)
          value = attributes_before_type_cast[name.to_s]

          # https://www.mongodb.com/docs/mongoid/current/reference/fields/#uncastable-values
          if self[name].nil? && !value.nil?
            # Uncastable value detected!
            self.errors.add(name, 'has a wrong object type')
          end
        end

        def add_json_parsing_error(name)
          error = instance_variable_get(:"@#{name}_json_parsing_error")

          if error
            msg = "Invalid #{name}: \"#{error}\". Check it out on http://jsonlint.com"
            self.errors.add(name, msg)
          end
        end

      end

    end
  end
end
