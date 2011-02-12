class Page

  include Locomotive::Mongoid::Document

  ## Extensions ##
  include Models::Extensions::Page::Tree
  include Models::Extensions::Page::EditableElements
  include Models::Extensions::Page::Parse
  include Models::Extensions::Page::Render
  include Models::Extensions::Page::Templatized
  include Models::Extensions::Page::Redirect
  include Models::Extensions::Page::Listed

  ## fields ##
  field :title
  field :slug
  field :fullpath
  field :raw_template
  field :published, :type => Boolean, :default => false
  field :cache_strategy, :default => 'none'

  ## associations ##
  referenced_in :site

  ## indexes ##
  index :site_id
  index :parent_id
  index [[:fullpath, Mongo::ASCENDING], [:site_id, Mongo::ASCENDING]]

  ## callbacks ##
  before_validation :normalize_slug
  before_save { |p| p.fullpath = p.fullpath(true) }
  before_destroy :do_not_remove_index_and_404_pages

  ## validations ##
  validates_presence_of     :site, :title, :slug
  validates_uniqueness_of   :slug, :scope => [:site_id, :parent_id]
  validates_exclusion_of    :slug, :in => Locomotive.config.reserved_slugs, :if => Proc.new { |p| p.depth == 0 }

  ## named scopes ##
  scope :latest_updated, :order_by => [[:updated_at, :desc]], :limit => Locomotive.config.lastest_items_nb
  scope :root, :where => { :slug => 'index', :depth => 0 }
  scope :not_found, :where => { :slug => '404', :depth => 0 }
  scope :published, :where => { :published => true }
  scope :fullpath, lambda { |fullpath| { :where => { :fullpath => fullpath } } }
  scope :minimal_attributes, :only => %w(title slug fullpath position depth published templatized listed parent_id created_at updated_at)

  ## methods ##

  def index?
    self.slug == 'index' && self.depth.to_i == 0
  end

  def not_found?
    self.slug == '404' && self.depth.to_i == 0
  end

  def index_or_not_found?
    self.index? || self.not_found?
  end

  def fullpath(force = false)
    if read_attribute(:fullpath).present? && !force
      return read_attribute(:fullpath)
    end

    if self.index? || self.not_found?
      self.slug
    else
      slugs = self.self_and_ancestors.map(&:slug)
      slugs.shift unless slugs.size == 1
      File.join slugs
    end
  end

  def url
    "http://#{self.site.domains.first}/#{self.fullpath}.html"
  end

  def with_cache?
    self.cache_strategy != 'none'
  end

  def to_liquid
    Locomotive::Liquid::Drops::Page.new(self)
  end

  protected

  def do_not_remove_index_and_404_pages
    return if self.site.nil? || self.site.destroyed?

    if self.index? || self.not_found?
      self.errors[:base] << I18n.t('errors.messages.protected_page')
    end

    self.errors.empty?
  end

  def normalize_slug
    self.slug = self.title.clone if self.slug.blank? && self.title.present?
    self.slug.slugify!(:without_extension => true) if self.slug.present?
  end

end
