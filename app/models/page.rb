class Page  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Acts::Tree
  
  ## fields ##
  field :title
  field :slug
  field :published, :type => Boolean, :default => false
  field :keywords
  field :description
  field :position, :type => Integer
  
  ## associations ##
  belongs_to_related :site
  belongs_to_related :layout
  embeds_many :parts, :class_name => 'PagePart'
    
  ## callbacks ##
  before_validate :reset_parent
  before_validate :normalize_slug
  before_save { |p| p.parent_id = nil if p.parent_id.blank? }
  before_save :change_parent
  before_create { |p| p.parts << PagePart.build_body_part if p.parts.empty? }
  before_create { |p| p.fix_position(false) }
  before_create :add_to_list_bottom
  before_destroy :do_not_remove_index_and_404_pages
  before_destroy :remove_from_list
  
  ## validations ##
  validates_presence_of     :site, :title, :slug
  validates_uniqueness_of   :slug, :scope => [:site_id, :parent_id]
  validates_exclusion_of    :slug, :in => Locomotive.config.reserved_slugs, :if => Proc.new { |p| p.depth == 0 }
  
  ## named scopes ##
  
  ## behaviours ##
  acts_as_tree :order => ['position', 'asc']
  
  ## methods ##
  
  def index?
    self.slug == 'index' && self.depth.to_i == 0
  end
  
  def not_found?
    self.slug == '404' && self.depth.to_i == 0
  end
  
  def parts_attributes=(attributes)    
    self.update_parts(attributes.values.map { |attrs| PagePart.new(attrs) })
  end
    
  def parent=(owner) # missing in acts_as_tree
    @_parent = owner
    self.fix_position(false)
    self.instance_variable_set :@_will_move, true
  end
  
  def sort_children!(ids)
    ids.each_with_index do |id, position|
      child = self.children.detect { |p| p._id == id }
      child.position = position
      child.save
    end
  end
  
  def route
    return self.slug if self.index? || self.not_found?    
    slugs = self.self_and_ancestors.map(&:slug)
    slugs.shift
    File.join slugs
  end
  
  def url
    "http://#{self.site.domains.first}/#{self.route}.html"
  end
  
  def ancestors
    return [] if root?
    self.class.find(self.path.clone << nil) # bug in mongoid (it does not handle array with one element) 
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
  
  def update_parts(parts)
    performed = []
    
    # add / update
    parts.each do |part|
      if (existing = self.parts.detect { |p| p.id == part.id || p.slug == part.slug })
        existing.attributes = part.attributes.delete_if { |k, v| %w{_id slug}.include?(k) }
      else
        self.parts << (existing = part)
      end
      performed << existing unless existing.disabled?
    end
    
    # disable missing parts
    (self.parts.map(&:slug) - performed.map(&:slug)).each do |slug|
      self.parts.detect { |p| p.slug == slug }.disabled = true
    end
  end
  
  def update_parts!(new_parts)
    self.update_parts(new_parts)
    self.save
  end
  
  def change_parent
    if self.parent_id_changed?
      self.fix_position(false)
      self.add_to_list_bottom
      self.instance_variable_set :@_will_move, true
    end
  end
  
  def fix_position(perform_save = true)
    if parent.nil?
      self[parent_id_field] = nil
      self[path_field] = []
      self[depth_field] = 0
    else
      self[parent_id_field] = parent._id
      self[path_field] = parent[path_field] + [parent._id]
      self[depth_field] = parent[depth_field] + 1
      self.save if perform_save
    end
  end
  
  def reset_parent
    if self.parent_id_changed?
      @_parent = nil
    end
  end
  
  def add_to_list_bottom  
    self.position = (Page.where(:_id.ne => self._id).and(:parent_id => self.parent_id).max(:position) || 0) + 1
  end
  
  def remove_from_list
    return if (self.site rescue nil).nil?
    
    Page.where(:parent_id => self.parent_id).and(:position.gt => self.position).each do |p|
      p.position -= 1
      p.save
    end
  end
    
  def normalize_slug  
    self.slug = self.title.clone if self.slug.blank? && self.title.present?    
    self.slug.slugify!(:without_extension => true) if self.slug.present?
  end
end