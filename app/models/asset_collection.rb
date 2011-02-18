class AssetCollection

  include Locomotive::Mongoid::Document

  ## fields ##
  field :name
  field :slug
  field :internal, :type => Boolean, :default => false

  ## associations ##
  referenced_in :site
  embeds_many :assets

  ## behaviours ##
  custom_fields_for :assets
  liquid_methods :name, :ordered_assets

  ## callbacks ##
  before_validation :normalize_slug
  before_save :store_asset_positions!
  after_destroy :remove_uploaded_files

  ## validations ##
  validates_presence_of :site, :name, :slug
  validates_uniqueness_of :slug, :scope => :site_id

  ## named scopes ##
  scope :internal, :where => { :internal => true }
  scope :not_internal, :where => { :internal => false }

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

  def self.find_or_create_internal(site)
    site.asset_collections.internal.first || site.asset_collections.create(:name => 'system', :slug => 'system', :internal => true)
  end

  protected

  def normalize_slug
    self.slug = self.name.clone if self.slug.blank? && self.name.present?
    self.slug.slugify! if self.slug.present?
  end

  def store_asset_positions!
    return if @assets_order.nil?

    ids = @assets_order.split(',').collect { |id| BSON::ObjectId(id) }

    ids.each_with_index do |asset_id, index|
      self.assets.find(asset_id).position = index
    end

    self.assets.clone.each do |asset|
      if !ids.include?(asset._id)
        self.assets.delete(asset)
        asset.send(:delete)
      end
    end
  end

  def remove_uploaded_files # callbacks are not called on each asset so we do it manually
    self.assets.each do |asset|
      self.asset_custom_fields.each do |field|
        asset.send(:"remove_#{field._name}!") if field.kind == 'file'
      end
    end
  end

end
