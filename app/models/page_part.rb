class PagePart
  include Mongoid::Document
  # include Mongoid::Timestamps  

  ## fields ##
  field :name, :type => String
  field :slug, :type => String
  field :value, :type => String
  field :disabled, :type => Boolean, :default => false
  field :value, :type => String
    
  ## associations ##
  embedded_in :page, :inverse_of => :parts
  
  # attr_accessor :_delete
  
  ## callbacks ##
  # before_validate  { |p| p.slug ||= p.name.slugify if p.name.present? }  
  
  ## validations ##
  validates_presence_of :name, :slug
  
  ## named scopes ##
  named_scope :enabled, where(:disabled => false)
  
  ## methods ##
  
  # def _delete=(value)
  #   puts "set _delete #{value.inspect}"
  #   self.attributes[:_destroy] = true if %w(t 1 true).include?(value)
  # end
  
  def self.build_body_part
    self.new(:name => I18n.t('admin.shared.attributes.body'), :slug => 'layout')
  end
end