module Locomotive
  class ContentType

    include Locomotive::Mongoid::Document

    ## extensions ##
    include ::CustomFields::Source
    include Concerns::Shared::SiteScope
    include Concerns::ContentType::Label
    include Concerns::ContentType::DefaultValues
    include Concerns::ContentType::EntryTemplate
    include Concerns::ContentType::Sync
    include Concerns::ContentType::GroupBy
    include Concerns::ContentType::OrderBy
    include Concerns::ContentType::ClassHelpers
    include Concerns::ContentType::PublicSubmissionTitleTemplate
    include Concerns::ContentType::FilterFields

    ## fields ##
    field :name
    field :description
    field :slug
    field :label_field_id,              type: BSON::ObjectId
    field :label_field_name
    field :group_by_field_id,           type: BSON::ObjectId
    field :order_by # either a BSON::ObjectId (field id) or a String (:_position, ...etc)
    field :order_direction,             default: 'asc'
    field :public_submission_enabled,   type: Boolean,  default: false
    field :public_submission_accounts,  type: Array,    default: []
    field :number_of_entries
    field :display_settings,            type: Hash

    ## associations ##
    has_many :entries,   class_name: 'Locomotive::ContentEntry', dependent: :destroy

    ## named scopes ##
    scope :ordered, -> { order_by(updated_at: :desc) }
    scope :by_id_or_slug, ->(id_or_slug) {
      any_of({ _id: id_or_slug }, { slug: id_or_slug })
    }
    scope :localized, -> { elem_match(entries_custom_fields: { localized: true }) }

    ## indexes ##
    # index site_id: 1, slug: 1

    ## callbacks ##
    before_validation   :normalize_slug
    before_validation   :sanitize_public_submission_accounts
    after_validation    :bubble_fields_errors_up

    ## validations ##
    validates_presence_of   :name, :slug
    validates_uniqueness_of :slug, scope: :site_id
    validates_size_of       :entries_custom_fields, minimum: 1, message: :too_few_custom_fields

    ## behaviours ##
    custom_fields_for :entries

    ## methods ##

    # Order the list of entries, paginate it if requested
    # and filter it.
    #
    # @param [ Hash ] options Options to filter (where key), order (order_by key) and paginate (page, per_page keys)
    #
    # @return [ Criteria ] A Mongoid criteria if not paginated (array otherwise).
    #
    def ordered_entries(options = nil)
      options ||= {}

      # pagination
      page, per_page = options.delete(:page), options.delete(:per_page)

      # order list
      _order_by_definition = (options || {}).delete(:order_by).try(:split) || self.order_by_definition

      # get list
      _entries = self.entries.order_by([_order_by_definition]).where(options[:where] || {})

      # pagination or full list
      page ? _entries.page(page).per(per_page) : _entries
    end

    # Find a custom field describing an entry based on its id
    # in first or its name if not found.
    #
    # @param [ String ] id_or_name The id of name of the field
    #
    # @return [ Object ] The custom field or nit if not found
    #
    def find_entries_custom_field(id_or_name)
      return nil if id_or_name.nil? # bypass the memoization

      _field = self.entries_custom_fields.find(id_or_name) rescue nil
      _field || self.entries_custom_fields.where(name: id_or_name).first
    end

    # A localized content type owns at least one localized field.
    def localized?
      self.entries_custom_fields.where(localized: true).count > 0
    end

    def hidden?
      (self.display_settings || {})['hidden']
    end

    def touch_site_attribute
      :content_version
    end

    protected

    def normalize_slug
      self.slug = self.name.clone if self.slug.blank? && self.name.present?
      self.slug.permalink!(true) if self.slug.present?
    end

    # We do not want to have a blank value in the list of accounts.
    def sanitize_public_submission_accounts
      if self.public_submission_accounts
        self.public_submission_accounts.reject! { |id| id.blank? }
      end
    end

    def bubble_fields_errors_up
      return if self.errors[:entries_custom_fields].empty?

      hash = { base: self.errors[:entries_custom_fields] }

      self.entries_custom_fields.each do |field|
        next if field.valid?
        key = field.persisted? ? field._id.to_s : field.position.to_i
        hash[key] = field.errors.to_a
      end

      self.errors.set(:entries_custom_fields, hash)
    end

    # Makes sure the class_name filled in a belongs_to or has_many field
    # does not belong to another site. Adds an error if it presents a
    # security problem.
    #
    # @param [ CustomFields::Field ] field The field to check
    #
    def ensure_class_name_security(field)
      if field.class_name =~ /^Locomotive::ContentEntry([a-z0-9]+)$/
        # if the content type does not exist (anymore), bypass the security checking
        content_type = Locomotive::ContentType.find($1) rescue nil

        return if content_type.nil?

        if content_type.site_id != self.site_id
          field.errors.add :class_name, :security
        end
      else
        # for now, does not allow external classes
        field.errors.add :class_name, :security
      end
    end

  end
end
