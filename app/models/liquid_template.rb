class LiquidTemplate
  
  include Locomotive::Mongoid::Document
  
  ## fields ##
  field :name
  field :slug
  field :value
  
  ## associations ##
  belongs_to_related :site
  
  ## callbacks ##
  before_validate :normalize_slug
  
  ## validations ##
  validates_presence_of   :site, :name, :slug, :value
  validates_uniqueness_of :slug, :scope => :site_id
  
  ## behaviours ##
  liquify_template :value
  
  ## methods ##
    
  protected
  
  def normalize_slug
    self.slug = self.name.clone if self.slug.blank? && self.name.present?
    self.slug.slugify!(:without_extension => true, :downcase => true) if self.slug.present?
  end
      
end