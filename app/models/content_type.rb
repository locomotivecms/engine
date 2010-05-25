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
  
  ## validations ##
  validates_presence_of :site, :name, :slug
  validates_uniqueness_of :slug, :scope => :site
  
  ## behaviours ##
  custom_fields_for :contents
  
  ## methods ##
  
  def ordered_contents
    self.contents.sort { |a, b| (a.position || 0) <=> (b.position || 0) }
  end
  
  def contents_order
    self.ordered_contents.collect(&:id).join(',')
  end
  
  def contents_order=(order)
    @contents_order = order
  end
  
  def highlighted_field
    self.content_custom_fields.detect { |f| f._name == self.highlighted_field_name }
  end
  
  protected
  
  def normalize_slug
    self.slug = self.name.clone if self.slug.blank? && self.name.present?    
    self.slug.slugify! if self.slug.present?
  end
  
end