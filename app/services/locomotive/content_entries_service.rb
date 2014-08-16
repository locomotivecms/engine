module Locomotive
  class ContentEntriesService

    def initialize(account, content_type)
      @content_type, @account = content_type, account
    end

    # List all the content entries of a content type.
    # The entries will be ordered depending on the content type settings.
    # If the content type has the group_by option on,
    # then the entries will be grouped by the group_by field.
    #
    # @param [ Hash ] options Options like: page, per_page (pagination) and q (for the search)
    #
    # @return [ Criteria ] List of entries (grouped or not)
    #
    def list(options = {})
      @content_entries = if options[:q]
        @content_type.ordered_entries(options)
      else
        @content_type.list_or_group_entries(options)
      end
    end

    # Create a content entry from the attributes passed in parameter.
    # It sets the created_by column with the current account.
    #
    # @param [ Hash ] attributes The attributes of new content entry.
    #
    # @return [ Object ] An instance of the content entry.
    def create(attributes)
      @content_type.entries.build(attributes).tap do |entry|
        entry.created_by = @account
        entry.save
      end
    end

    # Update a content entry defined by its id
    # from the attributes passed in parameter.
    # It sets the updated_by column with the current account.
    #
    # @param [ String ] id The id of the content entry to update.
    # @param [ Hash ] attributes The attributes of new content entry.
    #
    # @return [ Object ] The instance of the content entry.
    def update(id, attributes)
      @content_type.entries.find(id).tap do |entry|
        entry.attributes = attributes
        entry.updated_by = @account
        entry.save
      end
    end

  end
end