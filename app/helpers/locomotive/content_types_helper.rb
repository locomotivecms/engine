module Locomotive
  module ContentTypesHelper

    # Renders the label of a content type entry. If no raw_item_template filled in the content type,
    # it just calls the _label method of the entry (based on the label_field_id). Otherwise, it
    # parses and renders the liquid template.
    #
    # @param [ ContentType ] content_type The content type for better performance
    # @param [ ContentEntry] entry The entry we want to display the label
    #
    # @return [ String ] The label of the content type entry
    #
    def entry_label(content_type, entry)
      if content_type.raw_item_template.blank?
        entry._label # default one
      else
        assigns = { 'site' => current_site, 'entry' => entry }

        # TODO
        registers = {
          controller:     self,
          site:           current_site,
          current_locomotive_account:  current_locomotive_account,
          asset_host:     Locomotive::Liquid::AssetHost.new(request, current_site, Locomotive.config.asset_host)
        }

        preserve(content_type.item_template.render(::Liquid::Context.new({}, assigns, registers)))
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
