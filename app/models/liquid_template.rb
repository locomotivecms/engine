class LiquidTemplate  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ## fields ##
  field :name
  field :slug
  field :value
  field :template, :type => Binary
  
  ## associations ##
  belongs_to_related :site
  
  ## callbacks ##
  before_validate :normalize_slug
  before_validate :store_template
  
  ## validations ##
  validates_presence_of   :site, :name, :slug, :value
  validates_uniqueness_of :slug, :scope => :site_id
  
  ## methods ##
  
  def template
    Marshal.load(read_attribute(:template).to_s) rescue nil
  end
  
  protected
  
  def normalize_slug
    self.slug = self.name.clone if self.slug.blank? && self.name.present?
    self.slug.slugify!(:without_extension => true, :downcase => true) if self.slug.present?
  end
  
  def store_template
    begin
      parsed_template = Liquid::Template.parse(self.value)
      self.template = BSON::Binary.new(Marshal.dump(parsed_template))
    rescue Liquid::SyntaxError => error
      self.errors.add :value, :liquid_syntax_error
    end
  end
    
end