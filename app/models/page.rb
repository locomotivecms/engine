class Page
  
  include Locomotive::Mongoid::Document

  ## Extensions ##  
  include Models::Extensions::Page::Tree
  include Models::Extensions::Page::Parts
  include Models::Extensions::Page::Render
  
  ## fields ##
  field :title
  field :slug
  field :fullpath
  field :published, :type => Boolean, :default => false
  field :cache_expires_in, :type => Integer, :default => 0
  
  ## associations ##
  belongs_to_related :site
  belongs_to_related :layout
  embeds_many :parts, :class_name => 'PagePart'
    
  ## callbacks ##
  before_validate :normalize_slug
  before_save { |p| p.fullpath = p.fullpath(true) }
  before_destroy :do_not_remove_index_and_404_pages
  
  ## validations ##
  validates_presence_of     :site, :title, :slug
  validates_uniqueness_of   :slug, :scope => [:site_id, :parent_id]
  validates_exclusion_of    :slug, :in => Locomotive.config.reserved_slugs, :if => Proc.new { |p| p.depth == 0 }
  
  ## named scopes ##
  named_scope :latest_updated, :order_by => [[:updated_at, :desc]], :limit => Locomotive.config.lastest_items_nb
  named_scope :index, :where => { :slug => 'index', :depth => 0, :published => true }
  named_scope :not_found, :where => { :slug => '404', :depth => 0, :published => true }
  
  ## behaviours ##
  # liquid_methods :title, :fullpath
  liquify_template :joined_parts
  
  ## methods ##
  
  def index?
    self.slug == 'index' && self.depth.to_i == 0
  end
  
  def not_found?
    self.slug == '404' && self.depth.to_i == 0
  end
  
  def fullpath(force = false)
    if read_attribute(:fullpath).present? && !force
      return read_attribute(:fullpath)
    end
    
    if self.index? || self.not_found?
      self.slug
    else
      slugs = self.self_and_ancestors.map(&:slug)
      slugs.shift
      File.join slugs
    end
  end
  
  def url
    "http://#{self.site.domains.first}/#{self.fullpath}.html"
  end
  
  def to_liquid(options = {})
    Locomotive::Liquid::Drops::Page.new(self)
  end
    
  protected
  
  def do_not_remove_index_and_404_pages
    # safe_site = self.site rescue nil
    
    # return if safe_site.nil?
    return if (self.site rescue nil).nil?
    
    if self.index? || self.not_found?
      raise I18n.t('errors.messages.protected_page')
    end
  end
      
  def normalize_slug  
    self.slug = self.title.clone if self.slug.blank? && self.title.present?    
    self.slug.slugify!(:without_extension => true) if self.slug.present?
  end
    
end