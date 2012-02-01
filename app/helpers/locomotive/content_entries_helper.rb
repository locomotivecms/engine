module Locomotive::ContentEntriesHelper

  def options_for_belongs_to_custom_field(class_name)
    content_type = nil

    if class_name =~ /^Locomotive::Entry(.*)/
      content_type = current_site.content_types.find($1)
    end

    if content_type
      content_type.ordered_entries.map { |entry| [entry._label, entry._id] }
    else
      [] # unknown content type
    end
  end

end
