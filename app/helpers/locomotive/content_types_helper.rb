module Locomotive
  module ContentTypesHelper

    # Iterates over the content types with the following rules
    # - content types are ordered by the updated_at date (DESC)
    # - each content type has its own submenu if saved recently
    # - if there are more than ui.max_content_types content types, the extra ones go under "..."
    # - if a content type is selected and it is part of the extra content types, then
    #   it will be moved to the first position in the displayed list (with its own submenu)
    #
    # @param [ Block ] block The statements responsible to display the menu item from a content type or a list of content types
    #
    def each_content_type(&block)
      visible, others = [], []

      current_site.content_types.ordered.only(:site_id, :name, :slug, :label_field_name).each_with_index do |content_type, index|
        next if !content_type.persisted?

        if index >= Locomotive.config.ui[:max_content_types]
          if self.is_content_type_selected(content_type)
            others << visible.delete_at(Locomotive.config.ui[:max_content_types] - 1) # swap content types
            visible.insert(0, content_type)
          else
            others << content_type # fills the "..." menu
          end
          next
        end

        visible << content_type

      end.each do |content_type|
        # make sure to have a fresh copy of the content types because for now we don't have the full content types (ie: content_types.only(...))
        ::Mongoid::IdentityMap.remove(content_type)
      end

      if visible.size > 0
        visible.map { |c| yield(c) }
        yield(others) if others.size > 0
      end
    end

    def is_content_type_selected(content_type)
      @content_type && content_type.slug == @content_type.slug
    end

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
