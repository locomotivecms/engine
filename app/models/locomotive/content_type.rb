module Locomotive
  class ContentType

    include Locomotive::Mongoid::Document

    ## extensions ##
    include CustomFields::Source
    include Extensions::ContentType::DefaultValues
    include Extensions::ContentType::ItemTemplate
    include Extensions::ContentType::Sync

    ## fields ##
    field :name
    field :description
    field :slug
    field :label_field_id,              type: Moped::BSON::ObjectId
    field :label_field_name
    field :group_by_field_id,           type: Moped::BSON::ObjectId
    field :order_by
    field :order_direction,             default: 'asc'
    field :public_submission_enabled,   type: Boolean, default: false
    field :public_submission_accounts,  type: Array

    ## associations ##
    belongs_to  :site,      class_name: 'Locomotive::Site'
    has_many    :entries,   class_name: 'Locomotive::ContentEntry', dependent: :destroy do

      def find_by_id_or_permalink(id_or_permalink)
        any_of({ _id: id_or_permalink }, { _slug: id_or_permalink }).first
      end

      def safe_create(attributes = {})
        build.tap do |entry|
          entry.from_presenter(attributes)
          entry.save
        end
      end

    end

    ## named scopes ##
    scope :ordered, order_by(updated_at: :desc)

    ## indexes ##
    index site_id: 1, slug: 1

    ## callbacks ##
    before_validation   :normalize_slug
    before_validation   :sanitize_public_submission_accounts
    after_validation    :bubble_fields_errors_up
    before_update       :update_label_field_name_in_entries

    ## validations ##
    validates_presence_of   :site, :name, :slug
    validates_uniqueness_of :slug, scope: :site_id
    validates_size_of       :entries_custom_fields, minimum: 1, message: :too_few_custom_fields

    ## behaviours ##
    custom_fields_for :entries

    ## methods ##

    def order_manually?
      self.order_by == '_position'
    end

    def order_by_definition(reverse_order = false)
      direction = self.order_manually? ? 'asc' : self.order_direction || 'asc'

      if reverse_order
        direction = (direction == 'asc' ? 'desc' : 'asc')
      end

      [order_by_attribute, direction]
    end

    # Order the list of entries, paginate it if requested
    # and filter it.
    #
    # @param [ Hash ] options Options to filter and paginate.
    #
    # @return [ Criteria ] A Mongoid criteria if not paginated (array otherwise).
    #
    def ordered_entries(options = nil)
      options ||= {}

      page, per_page = options.delete(:page), options.delete(:per_page)

      # search for a label
      if options[:q]
        options[label_field_name.to_sym] = /#{options.delete(:q)}/i
      end

      # order list
      _order_by_definition = (options || {}).delete(:order_by).try(:split) || self.order_by_definition

      # get list
      _entries = self.entries.order_by([_order_by_definition]).where(options)

      # pagination or full list
      !self.order_manually? && page ? _entries.page(page).per(per_page) : _entries
    end

    def groupable?
      !!self.group_by_field && %w(select belongs_to).include?(group_by_field.type)
    end

    def group_by_field
      self.find_entries_custom_field(self.group_by_field_id)
    end

    def sortable_column
      # only the belongs_to field has a special column for relative positionning
      # that's why we don't call groupable?
      if self.group_by_field.try(:type) == 'belongs_to' && self.order_manually?
        "position_in_#{self.group_by_field.name}"
      else
        '_position'
      end
    end

    def list_or_group_entries(options = {})
      if self.groupable?
        if self.group_by_field.type == 'select'
          self.entries.group_by_select_option(self.group_by_field.name, self.order_by_definition)
        else
          group_by_belongs_to_field(self.group_by_field)
        end
      else
        self.ordered_entries(options)
      end
    end

    def class_name_to_content_type(class_name)
      self.class.class_name_to_content_type(class_name, self.site)
    end

    def label_field_id=(value)
      # update the label_field_name if the label_field_id is changed
      new_label_field_name = self.entries_custom_fields.where(_id: value).first.try(:name)
      self.label_field_name = new_label_field_name
      super(value)
    end

    def label_field_name=(value)
      # mandatory if we allow the API to set the label field name without an id of the field
      @new_label_field_name = value unless value.blank?
      super(value)
    end

    # Get the class name of the entries.
    #
    # @return [ String ] The class name of all the entries
    #
    def entries_class_name
      self.klass_with_custom_fields(:entries).to_s
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

    # Retrieve from a class name the associated content type within the scope of a site.
    # If no content type is found, the method returns nil
    #
    # @param [ String ] class_name The class name
    # @param [ Locomotive::Site ] site The Locomotive site
    #
    # @return [ Locomotive::ContentType ] The content type matching the class_name
    #
    def self.class_name_to_content_type(class_name, site)
      if class_name =~ /^Locomotive::ContentEntry(.*)/
        site.content_types.find($1)
      else
        nil
      end
    end

    protected

    def group_by_belongs_to_field(field)
      grouped_entries     = self.ordered_entries.group_by(&:"#{field.name}_id")
      columns             = grouped_entries.keys
      target_content_type = self.class_name_to_content_type(field.class_name)
      all_columns         = target_content_type.ordered_entries

      all_columns.map do |column|
        if columns.include?(column._id)
          {
            name:     column._label(target_content_type),
            entries:  grouped_entries.delete(column._id)
          }
        else
          nil
        end
      end.compact.tap do |groups|
        unless grouped_entries.empty? # "orphans" ?
          groups << { name: nil, entries: grouped_entries.values.flatten }
        end
      end
    end

    def order_by_attribute
      case self.order_by
      when '_position'
        self.sortable_column
      when 'created_at', 'updated_at'
        self.order_by
      else
        self.entries_custom_fields.find(self.order_by).name rescue 'created_at'
      end
    end

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

    def update_label_field_name_in_entries
      self.klass_with_custom_fields(:entries).update_all _label_field_name: self.label_field_name
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
        content_type = Locomotive::ContentType.find($1) rescue return

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

