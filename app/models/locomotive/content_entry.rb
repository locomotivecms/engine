module Locomotive
  class ContentEntry

    include Locomotive::Mongoid::Document

    ## extensions ##
    include ::CustomFields::Target
    include Concerns::Shared::SiteScope
    include Concerns::Shared::Seo
    include Concerns::Shared::Userstamp
    include Concerns::ContentEntry::Slug
    include Concerns::ContentEntry::Csv
    include Concerns::ContentEntry::Localized
    include Concerns::ContentEntry::Counter
    include Concerns::ContentEntry::FileSize
    include Concerns::ContentEntry::Authentication
    include Concerns::ContentEntry::NextPrevious

    ## fields ##
    field :_slug,             localize: true
    field :_position,         type: Integer, default: 0
    field :_visible,          type: Boolean, default: true

    ## validations ##
    validates_presence_of     :_slug
    validates_uniqueness_of   :_slug, scope: :content_type_id, allow_blank: true

    ## associations ##
    belongs_to  :content_type,  class_name: 'Locomotive::ContentType', inverse_of: :entries, custom_fields_parent_klass: true

    ## callbacks ##
    before_validation :set_site
    before_save       :set_visibility
    before_create     :add_to_list_bottom

    ## named scopes ##
    scope :visible, -> { where(_visible: true) }
    scope :latest_updated, -> { order_by(updated_at: :desc).limit(Locomotive.config.ui[:latest_entries_nb]) }
    scope :next_or_previous,
      ->(condition, order_by) { where({ _visible: true }.merge(condition)).limit(1).order_by(order_by) }
    scope :by_id_or_slug, ->(id_or_slug) { all.or({ _id: id_or_slug }, { _slug: id_or_slug }) }
    scope :by_ids_or_slugs, ->(ids_or_slugs) { all.or({ :_slug.in => [*ids_or_slugs] }, { :_id.in => [*ids_or_slugs] }) }

    ## indexes ##
    index _type: 1
    index site_id: 1, updated_at: 1
    index content_type_id: 1
    Locomotive.config.site_locales.each do |locale|
      index _type: 1, "_slug.#{locale}" => 1
      index content_type_id: 1, "_slug.#{locale}" => 1
    end
    index content_type_id: 1, created_at: 1
    index content_type_id: 1, _type: 1, created_at: 1
    index _type: 1, _position: 1
    index content_type_id: 1, _position: 1

    index site_id: 1, content_type_id: 1, _visible: 1
    index site_id: 1, content_type_id: 1, _visible: 1, _position: 1

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
      value = self.send(_label_field_name(type))

      value.respond_to?(:to_label) ? value.to_label : value.to_s
    end

    alias :to_label :_label

    def content_type_slug
      self.content_type.try(:slug)
    end

    def as_json(*args)
      super.tap { |json| json['_label'] = _label }
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

    # Find a content entry by its permalink or its id
    #
    # @param [ String ] The id_or_permalink Permalink (slug) or id
    #
    # @return [ Object ] The content entry matching the permalink/_id or nil if not found
    #
    def self.find_by_id_or_permalink(id_or_permalink)
        any_of({ _id: id_or_permalink }, { _slug: id_or_permalink }).first
      end

    # Sort the content entries from an ordered array of content entry ids.
    # Their new positions are persisted.
    #
    # @param [ Array ] content_type The content type describing the entries
    # @param [ Array ] The ordered array of ids
    #
    def self.sort_entries!(ids, column = :_position)
      list = self.any_in(_id: ids.map { |id| BSON::ObjectId.from_string(id.to_s) }).to_a
      ids.each_with_index do |id, position|
        if entry = list.detect { |e| e._id.to_s == id.to_s }
          entry.set column => position
        end
      end
    end

    def to_steam(type = nil)
      (type || self.content_type).to_steam_entry(self)
    end

    def to_liquid(type = nil)
      to_steam(type).to_liquid
    end

    def touch_site_attribute
      :content_version
    end

    protected

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

    def add_to_list_bottom
      max = self.class.indexed_max(:_position)
      self._position = max + 1 if max
    end

    def _label_field_name(type = nil)
      (type || self.content_type).label_field_name.to_sym
    end

  end
end
