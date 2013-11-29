module Locomotive
  module ContentEntriesHelper

    # Keep track of the form used to create / edit content entries
    # from a has_many custom field.
    # Because of formtastic which does not work with embedded forms,
    # we have to render them once we are done with our main form.
    #
    # @param [ Hash ] field The field describing the relationship
    #
    def push_has_many_form(field)
      (@has_many_forms ||= []) << field
    end

    # Render all the forms used to create / edit content entries
    # from a has_many custom field.
    # Because of formtastic which does not work with embedded forms,
    # we have to render them once we are done with our main form.
    #
    # @return [ String ] the forms
    #
    def render_has_many_forms
      return unless @has_many_forms

      @has_many_forms.map do |field|
        render 'locomotive/custom_fields/types/has_many_form', field: field
      end.join("\n").html_safe
    end

    def options_for_belongs_to_custom_field(class_name)
      content_type = Locomotive::ContentType.class_name_to_content_type(class_name, current_site)

      if content_type
        content_type.ordered_entries.map { |entry| [entry_label(content_type, entry), entry._id] }
      else
        [] # unknown content type
      end
    end

    # Display the label related to a field of a content entry.
    # If the field is not localized, we just display the label.
    # If the field is localized, then we display a nice flag icon
    # to let the end-user know about it.
    #
    # @param [ Object ] content_entry The content entry
    # @param [ Object ] field The custom field
    #
    # @return [ String ] The label with or without the icon
    #
    def label_for_custom_field(content_entry, field)
      if field.localized?
        translated_css = content_entry.translated_field?(field) ? '' : 'untranslated'

        icon  = content_tag(:i, '', class: 'icon-flag')
        tag   = content_tag(:span, icon, class: "localized-icon #{translated_css}")
        "#{tag}#{field.label}"
      else
        field.label
      end
    end

  end
end