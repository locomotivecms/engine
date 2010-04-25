class PagePart
  include Mongoid::Document
  include Mongoid::Timestamps  

  ## fields ##
  field :name, :type => String
  field :slug, :type => String
  field :value, :type => String
  field :disabled, :type => Boolean, :default => false
    
  ## associations ##
  embedded_in :page, :inverse_of => :parts
  
  ## validations ##
  validates_presence_of :name, :slug
  
  ## callbacks ##
  before_validate  { |p| p.slug ||= p.name.slugify if p.name.present? }
  
end