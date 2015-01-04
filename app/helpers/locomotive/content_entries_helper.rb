module Locomotive
  module ContentEntriesHelper

    # Display the name of the account (+ avatar) who created or updated the content entry
    # as well as the date when it happened.
    #
    # @param [ Object ] entry The content entry instance
    #
    # @return [ String ] The html output
    def content_entry_stamp(entry)
      distance = time_ago_in_words(entry.updated_at)

      if account = entry.updated_by || entry.created_by
        profile = account_avatar_and_name(account, '40x40#')
        key     = entry.updated_by ? :updated_by : :created_by
        t(key, scope: 'locomotive.content_entries.index', distance: distance, who: profile)
      else
        t('locomotive.content_entries.index.updated_at', distance: distance)
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

    def edit_content_entry_path_from_field(field, object, options = {})
      if id = object.send(:"#{field.name}_id")
        slug = field.class_name_to_content_type.slug

        edit_content_entry_path(slug, id, options)
      else
        nil
      end
    end

    def content_entries_path_from_field(field)
      slug = field.class_name_to_content_type.slug
      content_entries_path(slug, :json)
    end

  end
end
