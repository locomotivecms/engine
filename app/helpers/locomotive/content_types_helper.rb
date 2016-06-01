module Locomotive
  module ContentTypesHelper

    # Renders the label of a content type entry. If no entry_template filled in the content type,
    # it just calls the _label method of the entry (based on the label_field_id). Otherwise, it
    # parses and renders the liquid template.
    #
    # @param [ ContentType ] content_type The content type for better performance
    # @param [ ContentEntry] entry The entry we want to display the label
    #
    # @return [ String ] The label of the content type entry
    #
    def entry_label(content_type, entry)
      link = edit_content_entry_path(current_site, content_type.slug, entry)

      if content_type.entry_template.blank?
        label = entry._label(content_type).presence || t(:untranslated, scope: 'locomotive.shared.list')
        link_to label, link  # default one
      else
        assigns   = { 'site' => current_site, 'entry' => entry.to_liquid(content_type), 'link' => link, 'today' => Date.today, 'now' => Time.zone.now }
        registers = { site: current_site, locale: current_content_locale.to_s, services: Locomotive::Steam::Services.build_instance }
        context   = ::Liquid::Context.new({}, assigns, registers)

        content_type.render_entry_template(context).html_safe
      end
    end

    # List the fields which could be used to filter the content entries
    # in the back-office.
    # Not all the types are included. Only: string, text, integer, float, email
    #
    # @param [ ContentType ] content_type The content type owning the fields
    #
    # @return [ Array ] Used as it by the select_tag method
    #
    def options_for_filter_fields(content_type)
      allowed_types = %w(string text integer float email)
      fields = content_type.entries_custom_fields.where(:type.in => allowed_types)

      fields.map { |field| [field.label, field._id] }
    end

  end
end
