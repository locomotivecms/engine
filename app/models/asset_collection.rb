class AssetCollection
  
  include Locomotive::Mongoid::Document
  
  ## fields ##
  field :name
  field :slug
  
  ## associations ##
  belongs_to_related :site
  embeds_many :assets
  
  ## behaviours ##
  custom_fields_for :assets
  liquid_methods :name, :ordered_assets
  
  ## callbacks ##
  before_validate :normalize_slug
  before_save :store_asset_positions!
  
  ## validations ##
  validates_presence_of :site, :name, :slug
  validates_uniqueness_of :slug, :scope => :site_id
  
  ## methods ##
  
  def ordered_assets
    self.assets.sort { |a, b| (a.position || 0) <=> (b.position || 0) }
  end
  
  def assets_order
    self.ordered_assets.collect(&:id).join(',')
  end
  
  def assets_order=(order)
    @assets_order = order
  end
      
  protected
  
  def normalize_slug
    self.slug = self.name.clone if self.slug.blank? && self.name.present?    
    self.slug.slugify! if self.slug.present?
  end
  
  def store_asset_positions!
    return if @assets_order.nil?
    
    @assets_order.split(',').each_with_index do |asset_id, index|
      self.assets.find(asset_id).position = index
    end
    
    self.assets.each do |asset|
      if !@assets_order.split(',').include?(asset._id)
        self.assets.delete(asset) 
        asset.send(:delete)
      end
    end
  end
end