class ContentType  
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::CustomFields
  
  ## fields ##
  field :name
  field :description
  field :slug
  field :order_by
  
  ## associations ##
  belongs_to_related :site
  embeds_many :contents, :class_name => 'ContentInstance'

  ## callbacks ##
  before_validate :normalize_slug
  
  ## validations ##
  validates_presence_of :site, :name, :slug
  validates_uniqueness_of :slug, :scope => :site
  
  ## behaviours ##
  # custom_fields_for :contents
  
  ## methods ##
  
  protected
  
  def normalize_slug
    self.slug = self.name.clone if self.slug.blank? && self.name.present?    
    self.slug.slugify! if self.slug.present?
  end
  
end