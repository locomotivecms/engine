module Locomotive
  class ContentEntry

    include Locomotive::Mongoid::Document

    ## extensions ##
    include ::CustomFields::Target
    include Extensions::ContentEntry::Csv
    include Extensions::ContentEntry::Localized
    include Extensions::Shared::Seo

    ## fields ##
    field :_slug,             localize: true
    field :_label_field_name
    field :_position,         type: Integer, default: 0
    field :_visible,          type: Boolean, default: true

    ## validations ##
    validates_presence_of     :_slug
    validates_uniqueness_of   :_slug, scope: :content_type_id, allow_blank: true

    ## associations ##
    belongs_to  :site,          class_name: 'Locomotive::Site'
    belongs_to  :content_type,  class_name: 'Locomotive::ContentType', inverse_of: :entries, custom_fields_parent_klass: true

    ## callbacks ##
    before_validation :set_slug
    before_save       :set_site
    before_save       :set_visibility
    before_save       :set_label_field_name
    before_create     :add_to_list_bottom
    after_create      :send_notifications

    ## named scopes ##
    scope :visible, where(_visible: true)
    scope :latest_updated, order_by(updated_at: :desc).limit(Locomotive.config.ui[:latest_entries_nb])
    scope :next_or_previous, ->(condition, order_by) { where({ _visible: true }.merge(condition)).limit(1).order_by(order_by) }

    ## methods ##

    alias :visible? :_visible?
    alias :_permalink :_slug
    alias :_permalink= :_slug=

    # Any content entry owns a label property which is used in the back-office UI
    # to represent it. The field used as the label is defined within the parent content type.
    #
    # @param [ Object ] (optional) The content type to avoid to run another MongoDB and useless query.
    #
    # @return [ String ] The "label" of the content entry
    #
    def _label(type = nil)
      value = if self._label_field_name
        self.send(self._label_field_name.to_sym)
      else
        self.send((type || self.content_type).label_field_name.to_sym)
      end

      value.respond_to?(:to_label) ? value.to_label : value.to_s
    end

    alias :to_label :_label

    # Return the next content entry based on the order defined in the parent content type.
    #
    # @param [ Object ] The next content entry or nil if not found
    #
    def next
      next_or_previous :gt
    end

    # Return the previous content entry based on the order defined in the parent content type.
    #
    # @param [ Object ] The previous content entry or nil if not found
    #
    def previous
      next_or_previous :lt
    end

    # Find a content entry by its permalink
    #
    # @param [ String ] The permalink
    #
    # @return [ Object ] The content entry matching the permalink or nil if not found
    #
    def self.find_by_permalink(permalink)
      self.where(_slug: permalink).first
    end

    # Sort the content entries from an ordered array of content entry ids.
    # Their new positions are persisted.
    #
    # @param [ Array ] content_type The content type describing the entries
    # @param [ Array ] The ordered array of ids
    #
    def self.sort_entries!(ids, column = :_position)
      list = self.any_in(_id: ids.map { |id| Moped::BSON::ObjectId.from_string(id.to_s) }).to_a
      ids.each_with_index do |id, position|
        if entry = list.detect { |e| e._id.to_s == id.to_s }
          entry.update_attributes column => position
        end
      end
    end

    # All the content entries no matter the content type they belong to
    # share the same presenter class.
    #
    # @param [ Class ] The content entry presenter class
    #
    def self.presenter_class
      Locomotive::ContentEntryPresenter
    end

    # All the content entries no matter the content type they belong to
    # share the same liquid drop class.
    #
    # @param [ Class ] The liquid drop class
    #
    def self.drop_class
      Locomotive::Liquid::Drops::ContentEntry
    end

    protected

    # Retrieve the next or the previous entry following the order
    # defined in the parent content type.
    #
    # @param [ Symbol ] :gt for the next element, :lt for the previous element
    #
    # @return [ Object ] The next or previous content entry or nil if none
    #
    def next_or_previous(matcher = :gt)
      attribute, direction = self.content_type.order_by_definition(matcher == :lt)

      criterion = attribute.to_sym.send(matcher)
      value     = self.send(attribute.to_sym)
      order_by  = [attribute, direction]

      self.class.next_or_previous({ criterion => value }, order_by).first
    end

    # Set the slug of the instance by using the value of the highlighted field
    # (if available). If a sibling content instance has the same permalink then a
    # unique one will be generated
    def set_slug
      self._slug = self._label.dup if self._slug.blank? && self._label.present?

      if self._slug.present?
        self._slug.permalink!

        self._slug = self.next_unique_slug if self.slug_already_taken?
      end

      # all the site locales share the same slug ONLY IF the entry is not localized.
      self.set_same_slug_for_all_site_locales if !self.localized?
    end

    # For each locale of the site, we set the slug
    # coming from the value for the default locale.
    def set_same_slug_for_all_site_locales
      return unless self.set_site.localized?

      default_slug = self._slug

      self.set_site.locales.each do |locale|
        ::Mongoid::Fields::I18n.with_locale(locale) do
          self._slug = default_slug
        end
      end
    end

    # Return the next available unique slug as a string
    def next_unique_slug
      slug        = self._slug.gsub(/-\d+$/, '')
      similar_slugs   = self.class.where(:_id.ne => self._id, _slug: /^#{slug}-?\d*$/i)
      next_number = similar_slugs.map {|s| s._slug.scan(/-(\d+)$/).flatten.last.to_i }.max + 1
      [slug, next_number].join('-')
    end

    def slug_already_taken?
      self.class.where(:_id.ne => self._id, _slug: self._slug).any?
    end

    def set_site
      self.site ||= self.content_type.site
    end

    def set_visibility
      if self.respond_to?(:visible)
        self.visible  = true if self.visible.nil?
        self._visible = self.visible
        return
      end
    end

    def set_label_field_name
      self._label_field_name = self.content_type.label_field_name
    end

    def add_to_list_bottom
      unless self.class.empty?
        self._position = self.class.max(:_position).to_i + 1
      end
    end

    def send_notifications
      return if !self.content_type.public_submission_enabled? || self.content_type.public_submission_accounts.blank?

      account_ids = self.content_type.public_submission_accounts.map(&:to_s)

      self.site.accounts.each do |account|
        next unless account_ids.include?(account._id.to_s)

        Locomotive::Notifications.new_content_entry(account, self).deliver
      end
    end

  end
end
