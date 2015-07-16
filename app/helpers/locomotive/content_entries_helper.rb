module Locomotive
  module ContentEntriesHelper

    # Tell if the tab specified by the name argument should
    # be displayed or not. It is based on the display_settings
    # property of the content type.
    def display_content_entry_tab?(content_type, name)
      return true if content_type.display_settings.blank?

      content_type.display_settings[name.to_s] != false
    end

    # Display the label related to a field of a content entry.
    # If the field is not localized, we just display the label.
    # If the field is localized, then we display a nice flag icon
    # to let the end-user know about it.
    #
    # @param [ Object ] entry The content entry
    # @param [ Object ] field The custom field
    #
    # @return [ String ] The label with or without the icon
    #
    def label_for_custom_field(entry, field)
      if field.localized?
        translated_css = entry.translated_field?(field) ? '' : 'untranslated'

        icon = content_tag(:i, '', class: "fa fa-globe #{translated_css}")

        "#{icon}&nbsp;#{field.label}".html_safe
      else
        field.label
      end
    end

    # List the labels and url of "groups" used to group the entries
    # of a content type. 2 sources:
    # - from a select field
    # - from a belongs_to field
    #
    # @param [ Object ] content_type The content type
    #
    # @return [ Array ] The list of labels and urls (Hash)
    #
    def each_content_entry_group(content_type, &block)
      field   = content_type.group_by_field
      groups  = content_type.list_of_groups || []

      groups.each do |group|
        block.call({
          name: group[:name],
          url:  content_entries_path(current_site, content_type.slug, {
            group:  group[:name],
            where:  %({"#{field.name}_id": "#{group[:_id]}"}),
            q:      params[:q]
          })
        })
      end
    end

    def can_edit_public_submission_accounts?(content_type)
      policy(content_type).update? && content_type.public_submission_enabled?
    end

  end
end
