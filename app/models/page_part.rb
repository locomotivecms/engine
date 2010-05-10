class PagePart
  include Mongoid::Document

  ## fields ##
  field :name, :type => String
  field :slug, :type => String
  field :value, :type => String
  field :disabled, :type => Boolean, :default => false
  field :value, :type => String
    
  ## associations ##
  embedded_in :page, :inverse_of => :parts
  
  ## callbacks ##
  # before_validate  { |p| p.slug ||= p.name.slugify if p.name.present? }  
  
  ## validations ##
  validates_presence_of :name, :slug
  
  ## named scopes ##
  named_scope :enabled, where(:disabled => false)
  
  ## methods ##
  
  def self.build_body_part
    self.new({
      :name => I18n.t('attributes.defaults.page_parts.name'), 
      :value => I18n.t('attributes.defaults.pages.other.body'), 
      :slug => 'layout'
    })
  end
end