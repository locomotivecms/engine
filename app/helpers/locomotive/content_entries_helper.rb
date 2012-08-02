module Locomotive
  module ContentEntriesHelper

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