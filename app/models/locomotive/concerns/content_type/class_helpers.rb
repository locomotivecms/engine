module Locomotive
  module Concerns
    module ContentType
      module ClassHelpers

        extend ActiveSupport::Concern

        def class_name_to_content_type(class_name)
          self.class.class_name_to_content_type(class_name, self.site)
        end

        # Get the class of the entries
        #
        # @return [ Class ] The class of the entries
        #
        def entries_class
          self.klass_with_custom_fields(:entries)
        end

        # Get the class name of the entries.
        #
        # @return [ String ] The class name of all the entries
        #
        def entries_class_name
          self.entries_class.to_s
        end

        protected

        # Make sure the class_name filled in a belongs_to or has_many field
        # does not belong to another site. Adds an error if it presents a
        # security problem.
        #
        # @param [ CustomFields::Field ] field The field to check
        #
        def ensure_class_name_security(field)
          if field.class_name =~ /^Locomotive::ContentEntry([a-z0-9]+)$/
            # if the content type does not exist (anymore), bypass the security checking
            content_type = Locomotive::ContentType.find($1) rescue return

            if content_type.site_id != self.site_id
              field.errors.add :class_name, :security
            end
          else
            # for now, does not allow external classes
            field.errors.add :class_name, :security
          end
        end

        public module ClassMethods

          # Retrieve from a class name the associated content type within the scope of a site.
          # If no content type is found, the method returns nil
          #
          # @param [ String ] class_name The class name
          # @param [ Locomotive::Site ] site The Locomotive site
          #
          # @return [ Locomotive::ContentType ] The content type matching the class_name
          #
          def class_name_to_content_type(class_name, site)
            if class_name =~ /^Locomotive::ContentEntry(.*)/
              site.content_types.find($1)
            else
              nil
            end
          end

        end

      end
    end
  end
end
