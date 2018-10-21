module Locomotive
  class ContentEntryService < Struct.new(:content_type, :account)

    include Locomotive::Concerns::ActivityService

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
    # The no_pagination option is used to skip the pagination of the content entries
    #
    # @param [ Hash ] options The options for the pagination and the filtering
    #
    # @return [ Object ] a paginated list of content entries
    #
    def all(options = {})
      _options = prepare_options_for_all(options)

      content_type.ordered_entries(_options)
    end

    # Sort the entries of a content type.
    #
    # @param [ Array ] ids Ordered list of content entry ids.
    #
    def sort(ids)
      klass = self.content_type.klass_with_custom_fields(:entries)
      klass.sort_entries!(ids, self.content_type.sortable_column)

      # we need to clear out the cache
      content_type.site.touch(:content_version)

      track_activity 'content_entry.sorted', parameters: activity_parameters
    end

    # Create a content entry from the attributes passed in parameter.
    # It sets the created_by column with the current account.
    #
    # @param [ Hash ] attributes The attributes of new content entry.
    #
    # @return [ Object ] An instance of the content entry.
    #
    def create(attributes)
      sanitize_attributes!(attributes)

      content_type.entries.build(attributes).tap do |entry|
        entry.created_by = account if account

        if entry.save
          track_activity 'content_entry.created', parameters: activity_parameters(entry)
        end
      end
    end

    def create!(attributes)
      if (entry = create(attributes)).errors.empty?
        entry
      else
        entry.fail_due_to_validation!
      end
    end

    # Create a content entry from the attributes passed in parameter.
    # It does not set the created_by column since it's called
    # from the public side of the site with no logged in account.
    # The attributes are filtered through the Grape::Entity / Form.
    # A notification email is sent to the selected members of the site.
    #
    # @param [ Hash ] attributes The attributes of new content entry.
    # @param [ Hash ] options For now, only store the ip address of the person who submitted the content entry.
    #
    # @return [ Object ] An instance of the content entry.
    #
    def public_create(attributes, options = {})
      form = Locomotive::API::Forms::ContentEntryForm.new(self.content_type, attributes)

      without_tracking_activity { create(form.serializable_hash) }.tap do |entry|
        if entry.errors.empty?
          # send an email to selected local accounts
          send_notifications(entry)

          track_activity 'content_entry.created_public', parameters: activity_parameters(entry)
        end
      end
    end

    # Update a content entry from the attributes passed in parameter.
    # It sets the updated_by column with the current account.
    #
    # @param [ Object ] entry The content entry to update.
    # @param [ Hash ] attributes The attributes of new content entry.
    #
    # @return [ Object ] The instance of the content entry.
    #
    def update(entry, attributes)
      sanitize_attributes!(attributes)

      entry.tap do |entry|
        entry.attributes = attributes
        entry.updated_by = account

        if entry.save
          track_activity 'content_entry.updated', parameters: activity_parameters(entry)
        end
      end
    end

    def update!(entry, attributes)
      update(entry, attributes)

      if entry.errors.empty?
        entry
      else
        entry.fail_due_to_validation!
      end
    end

    def destroy(entry)
      entry.destroy.tap do
        track_activity 'content_entry.destroyed', parameters: activity_parameters(entry)
      end
    end

    # Make sure the content entries has a non-blank slug in the new locales.
    # We take the slug in the default locale or the previous default locale (if provided)
    #
    def localize(new_locales, previous_default_locale)
      default_locale = previous_default_locale || content_type.site.default_locale

      content_type.entries.each_by(50) do |entry|
        slug = entry._slug_translations[default_locale]

        new_locales.each do |locale|
          next if locale == default_locale

          ::Mongoid::Fields::I18n.with_locale(locale) do
            entry._slug ||= slug
          end
        end

        entry.save if entry.changed?
      end
    end

    # Destroy all the entries of a content type.
    # Runs each entry's destroy callbacks.
    #
    def destroy_all
      content_type.entries.destroy_all
    end

    def send_notifications(entry)
      return unless self.content_type.public_submission_enabled?

      account_ids = (self.content_type.public_submission_accounts || []).map(&:to_s)

      self.content_type.site.accounts.each do |account|
        next unless account_ids.include?(account._id.to_s)

        Locomotive::Notifications.new_content_entry(account, entry).deliver
      end
    end

    # Give the list of permitted attributes for a content entry.
    # It includes:
    # - the default ones (_slug, seo, ...etc)
    # - the dynamic simple attributes (strings, texts, dates, belongs_to, ...etc)
    # - the relationships (has_many + many_to_many)
    #
    # @return [ Array ] List of permitted attributes
    #
    def permitted_attributes
      # needed to get the custom fields
      _entry = content_type.entries.build

      default     = %w(_slug _position _visible seo_title meta_keywords meta_description)
      dynamic     = _entry.custom_fields_safe_setters
      referenced  = {}

      # has_many
      has_many = _entry.has_many_custom_fields.each do |n, inverse_of|
        referenced["#{n}_attributes"] = [:_id, :_destroy, :"position_in_#{inverse_of}"]
      end

      # many_to_many
      many_to_many = _entry.many_to_many_custom_fields.each do |(_, s)|
        referenced[s] = []
      end

      (default + dynamic + [referenced.empty? ? nil : referenced]).compact
    end

    def site
      self.content_type.site
    end

    protected

    def sanitize_attributes!(attributes)
      # needed to get the custom fields
      _entry = content_type.entries.build

      # if the user deletes all the entries of a many_to_many field,
      # make sure the list gets empty instead of nil.
      _entry.many_to_many_custom_fields.each do |(n, s)|
        next unless content_type.is_field_with_ui_enabled?(n)

        # we don't want to clear the relationship with the form doesn't display the field
        attributes[s] = [] unless attributes.has_key?(s)
      end
    end

    def prepare_options_for_all(options)
      { where: prepare_where_statement(options) }.tap do |_options|
        unless options[:no_pagination]
          _options[:page]     = options[:page] || 1
          _options[:per_page] = options[:per_page] || Locomotive.config.ui[:per_page]
        end

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
      regexp = /.*#{query.split.map { |q| Regexp.escape(q) }.join('.*')}.*/i

      {}.tap do |where|
        if self.content_type.filter_fields.blank?
          where[content_type.label_field_name.to_sym] = regexp
        else
          where['$or'] = []
          self.content_type.filter_fields.each do |field_name|
            where['$or'] << { field_name => regexp }
          end
        end
      end
    end

    def activity_parameters(entry = nil)
      {
        _id:                entry.try(:_id),
        label:              entry.try(:_label),
        content_type:       content_type.name,
        content_type_slug:  content_type.slug
      }
    end

  end
end
