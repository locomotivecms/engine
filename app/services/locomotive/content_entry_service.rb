module Locomotive
  class ContentEntryService < Struct.new(:content_type)

    # List all the entries of a content type.
    #
    # If the content type allows the pagination, in other words, if the entries are not
    # ordered by the position column), then this method will return
    # a paginated list of entries.
    #
    # This list can also be filtered by the _label attribute, by setting the "q" key in the options.
    #
    # For a more powerful search, you can use the "where" key which accepts a JSON string or a Hash.
    #
    # @param [ Hash ] options The options for the pagination and the filtering
    #
    # @return [ Object ] a paginated list of content entries
    #
    def all(options = {})
      _options = prepare_options_for_all(options)

      if _options[:grouping]
        content_type.list_or_group_entries(_options)
      else
        content_type.ordered_entries(_options)
      end
    end

    # Destroy all the entries of a content type.
    # Runs each entry's destroy callbacks.
    #
    def destroy_all
      content_type.entries.destroy_all
    end

    protected

    def prepare_options_for_all(options)
      where = prepare_where_statement(options)

      {
        page:           options[:page] || 1,
        per_page:       options[:per_page] || Locomotive.config.ui[:per_page],
        grouping:       options[:grouping] || options[:q].blank?,
        where:          where
      }.tap do |_options|
        _options[:order_by] = options[:order_by] if options[:order_by]
      end
    end

    def prepare_where_statement(options)
      where = (case options[:where]
      when String then options[:where].blank? ? {} : JSON.parse(options[:where])
      when Hash   then options[:where]
      else {}
      end).with_indifferent_access

      if options[:q]
        where.merge!(prepare_query_statement(options[:q]))
      end

      where
    end

    def prepare_query_statement(query)
      regexp  = /.*#{query.split.map { |q| Regexp.escape(q) }.join('.*')}.*/i

      {}.tap do |where|
        if self.content_type.filter_fields.blank?
          where[content_type.label_field_name.to_sym] = regexp
        else
          where['$or'] = []
          self.content_type.filter_fields.each do |field_id|
            field = self.content_type.entries_custom_fields.find(field_id)
            where['$or'] << { field.name => regexp }
          end
        end
      end
    end

  end
end
