module Locomotive
  module Extensions
    module ContentEntry
      module Localized

        # Tell if the content entry has been translated or not.
        # It just checks if the field used for the label has been translated.
        # It assumes the entry is localized.
        #
        # @return [ Boolean ] True if translated, false otherwise
        #
        def translated?
          if self.respond_to?(:"#{self._label_field_name}_translations")
            self.send(:"#{self._label_field_name}_translations").key?(::Mongoid::Fields::I18n.locale.to_s) #rescue false
          else
            true
          end
        end

        # Return the locales the content entry has been translated to.
        #
        # @return [ Array ] The list of locales. Nil if not localized
        #
        def translated_in
          if self.localized?
            self.send(:"#{self._label_field_name}_translations").keys
          else
            nil
          end
        end

        # Tell if the field of the content entry has been translated
        # in the current locale or not.
        #
        # @param [ String/Object ] field The field or the name of the field
        #
        # @return [ Boolean ] True if translated, false if not, nil if the field is not localized
        #
        def translated_field?(field_or_name)
          field = field_or_name.respond_to?(:name) ? field_or_name : self.fields[field_or_name.to_s]

          if field.try(:localized?)
            locale = ::Mongoid::Fields::I18n.locale.to_s
            (self.attributes[field.name] || {}).key?(locale)
          else
            nil
          end
        end

        # Tell if the entry is localized or not, meaning if the label field
        # is localized or not.
        #
        # @return [ Boolean ] True if localized, false otherwise
        #
        def localized?
          self.respond_to?(:"#{self._label_field_name}_translations")
        end

      end
    end
  end
end