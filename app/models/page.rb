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
  embeds_many :parts, :class_name => 'PagePart'
  
  ## validations ##
  validates_presence_of     :site, :title, :slug
  validates_uniqueness_of   :slug, :scope => :site_id
  validates_exclusion_of    :slug, :in => Locomotive.config.reserved_slugs, :if => Proc.new { |p| p.depth == 0 }
  
  ## callbacks ##
  before_create :add_to_list_bottom
  before_create :add_body_part
  before_destroy :remove_from_list
  before_validate :normalize_slug
  
  ## named scopes ##
  
  ## behaviours ##
  acts_as_tree
  
  ## methods ##
  
  def add_body_part
    self.parts.build :name => 'body', :value => '---body here---'
  end
    
  def parent=(owner) # missing in acts_as_tree
    self[self.parent_id_field] = owner._id
    self[self.path_field] = owner[owner.path_field] + [owner._id]
    self[self.depth_field] = owner[owner.depth_field] + 1
    self.instance_variable_set :@_will_move, true
  end
  
  def route
    File.join self.self_and_ancestors.map(&:slug)
  end
  
  protected
  
  def add_to_list_bottom      
    self.position = (Page.where(:_id.ne => self._id).and(:parent_id => self.parent_id).max(:position) || 0) + 1
  end
  
  def remove_from_list
    Page.where(:parent_id => self.parent_id).and(:position.gt => self.position).each do |p|
      p.position -= 1
      p.save
    end
  end
  
  def normalize_slug
    self.slug.slugify!(:without_extension => true) if self.slug.present?
  end
end