module Locomotive
  class ContentType

    include Locomotive::Mongoid::Document

    ## extensions ##
    include CustomFields::Source
    include Extensions::ContentType::ItemTemplate

    ## fields ##
    field :name
    field :description
    field :slug
    field :label_field_id,              :type => BSON::ObjectId
    field :label_field_name
    field :group_by_field_id,           :type => BSON::ObjectId
    field :order_by
    field :order_direction,             :default => 'asc'
    field :public_submission_enabled,   :type => Boolean, :default => false
    field :public_submission_accounts,  :type => Array

    ## associations ##
    belongs_to  :site,      :class_name => 'Locomotive::Site'
    has_many    :entries,   :class_name => 'Locomotive::ContentEntry', :dependent => :destroy

    ## named scopes ##
    scope :ordered, :order_by => :updated_at.desc

    ## indexes ##
    index [[:site_id, Mongo::ASCENDING], [:slug, Mongo::ASCENDING]]

    ## callbacks ##
    before_validation   :normalize_slug
    after_validation    :bubble_fields_errors_up
    before_save         :set_default_values
    before_update       :update_label_field_name_in_entries

    ## validations ##
    validates_presence_of   :site, :name, :slug
    validates_uniqueness_of :slug, :scope => :site_id
    validates_size_of       :entries_custom_fields, :minimum => 1, :message => :too_few_custom_fields

    ## behaviours ##
    custom_fields_for :entries

    ## methods ##

    def order_manually?
      self.order_by == '_position'
    end

    def order_by_definition
      direction = self.order_manually? ? 'asc' : self.order_direction || 'asc'
      [order_by_attribute, direction]
    end

    def ordered_entries(conditions = {})
      self.entries.order_by([order_by_definition]).where(conditions)
    end

    def groupable?
      !!self.group_by_field && group_by_field.type == 'select'
    end

    def group_by_field
      self.entries_custom_fields.find(self.group_by_field_id) rescue nil
    end

    def list_or_group_entries
      if self.groupable?
        self.entries.group_by_select_option(self.group_by_field.name, self.order_by_definition)
      else
        self.ordered_entries
      end
    end

    def class_name_to_content_type(class_name)
      self.class.class_name_to_content_type(class_name, self.site)
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
      if class_name =~ /^Locomotive::Entry(.*)/
        site.content_types.find($1)
      else
        nil
      end
    end

    def to_presenter
      Locomotive::ContentTypePresenter.new(self)
    end

    def as_json(options = {})
      self.to_presenter.as_json
    end

    protected

    def order_by_attribute
      return self.order_by if %w(created_at updated_at _position).include?(self.order_by)
      self.entries_custom_fields.find(self.order_by).name rescue 'created_at'
    end

    def set_default_values
      self.order_by ||= 'created_at'
      self.label_field_id = self.entries_custom_fields.first._id if self.label_field_id.blank?
      field = self.entries_custom_fields.find(self.label_field_id)

      # the label field should always be required
      field.required = true

      self.label_field_name = field.name
    end

    def normalize_slug
      self.slug = self.name.clone if self.slug.blank? && self.name.present?
      self.slug.permalink! if self.slug.present?
    end

    def bubble_fields_errors_up
      return if self.errors[:entries_custom_fields].empty?

      hash = { :base => self.errors[:entries_custom_fields] }

      self.entries_custom_fields.each do |field|
        next if field.valid?
        key = field.persisted? ? field._id.to_s : field.position.to_i
        hash[key] = field.errors.to_a
      end

      self.errors.set(:entries_custom_fields, hash)
    end

    def update_label_field_name_in_entries
      self.klass_with_custom_fields(:entries).update_all :_label_field_name => self.label_field_name
    end

    # Makes sure the class_name filled in a belongs_to or has_many field
    # does not belong to another site. Adds an error if it presents a
    # security problem.
    #
    # @param [ CustomFields::Field ] field The field to check
    #
    def ensure_class_name_security(field)
      if field.class_name =~ /^Locomotive::Entry([a-z0-9]+)$/
        content_type = Locomotive::ContentType.find($1)

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

# def list_or_group_contents
#   if self.groupable?
#     groups = self.contents.klass.send(:"group_by_#{self.group_by_field._alias}", :ordered_contents)
#
#     # look for items with no category or unknown ones
#     items_without_category = self.contents.find_all { |c| !self.group_by_field.category_ids.include?(c.send(self.group_by_field_name)) }
#     if not items_without_category.empty?
#       groups << { :name => nil, :items => items_without_category }
#     else
#       groups
#     end
#   else
#     self.ordered_contents
#   end
# end
#
# def latest_updated_contents
#   self.contents.latest_updated.reject { |c| !c.persisted? }
# end
#
# def ordered_contents(conditions = {})
#   column = self.order_by.to_sym
#
#   list = (if conditions.nil? || conditions.empty?
#     self.contents
#   else
#     conditions_with_names = {}
#
#     conditions.each do |key, value|
#       # convert alias (key) to name
#       field = self.entries_custom_fields.detect { |f| f._alias == key }
#
#       case field.kind.to_sym
#       when :category
#         if (category_item = field.category_items.where(:name => value).first).present?
#           conditions_with_names[field._name.to_sym] = category_item._id
#         end
#       else
#         conditions_with_names[field._name.to_sym] = value
#       end
#     end
#
#     self.contents.where(conditions_with_names)
#   end).sort { |a, b| (a.send(column) && b.send(column)) ? (a.send(column) || 0) <=> (b.send(column) || 0) : 0 }
#
#   return list if self.order_manually?
#
#   self.asc_order? ? list : list.reverse
# end
#
# def sort_contents!(ids)
#   ids.each_with_index do |id, position|
#     self.contents.find(BSON::ObjectId(id))._position_in_list = position
#   end
#   self.save
# end
#
# def group_by_field
#   @group_by_field ||= self.entries_custom_fields.detect { |f| f._name == self.group_by_field_name }
# end