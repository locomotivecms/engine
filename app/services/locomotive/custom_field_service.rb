module Locomotive
  class CustomFieldService < Struct.new(:field, :locale)

    # Update the options of a "select" field.
    #
    # @param [ Hash ] options It includes the following keys: name, _id and _destroyed (if persisted)
    #
    # @return [ Array ] The new list of options
    #
    def update_select_options(options)
      return nil if options.blank?

      default_locale      = field._parent.site.default_locale.to_sym
      include_new_options = false

      # set the right position
      options.each_with_index do |option, position|
        option['position'] = position
        include_new_options = true if option['_id'].blank?
      end

      self.field.select_options_attributes = options

      save_field

      # make sure the new options are also available in the default locale
      if include_new_options && locale != default_locale
        ::Mongoid::Fields::I18n.with_locale(default_locale) do
          self.field.reload.select_options.each do |option|
            next unless option.attributes[:name][default_locale].blank?

            # force the name in the default locale
            option.name = option.attributes[:name].values.first
          end
        end

        save_field # we have to save it again and that's okay
      end

      self.field.select_options
    end

    private

    def save_field
      # save the content type so that all the content entries get a fresh version
      # of the custom fields rules
      self.field.save
      self.field._parent.save
    end

  end
end
