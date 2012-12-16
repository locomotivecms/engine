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

  end
end