class ContentType  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::CustomFields
  
  ## fields ##
  field :name
  field :description
  field :slug
  field :order_by
  field :highlighted_field_name
  
  ## associations ##
  belongs_to_related :site
  embeds_many :contents, :class_name => 'ContentInstance'

  ## callbacks ##
  before_validate :normalize_slug
  before_save :set_default_values
  
  ## validations ##
  validates_presence_of :site, :name, :slug
  validates_uniqueness_of :slug, :scope => :site
  validates_size_of :content_custom_fields, :minimum => 1, :message => :array_too_short
  
  ## behaviours ##
  custom_fields_for :contents
  
  ## methods ##
  
  def ordered_contents(conditions = {})
    column = self.order_by.to_sym
    
    (if conditions.nil? || conditions.empty?
      self.contents
    else
      self.contents.where(conditions)
    end).sort { |a, b| (a.send(column) || 0) <=> (b.send(column) || 0) }
  end
  
  def sort_contents!(order)
    order.split(',').each_with_index do |id, position|
      self.contents.find(id)._position_in_list = position
    end
    self.save
  end
  
  def highlighted_field
    self.content_custom_fields.detect { |f| f._name == self.highlighted_field_name }
  end
  
  protected
  
  def set_default_values
    self.order_by ||= 'updated_at'
    self.highlighted_field_name ||= self.content_custom_fields.first._name
  end
  
  def normalize_slug
    self.slug = self.name.clone if self.slug.blank? && self.name.present?    
    self.slug.slugify! if self.slug.present?
  end
  
end