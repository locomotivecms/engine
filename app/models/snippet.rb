class Snippet

  include Locomotive::Mongoid::Document

  ## fields ##
  field :name
  field :slug
  field :template

  ## associations ##
  referenced_in :site

  ## callbacks ##
  before_validation :normalize_slug

  ## validations ##
  validates_presence_of   :site, :name, :slug, :template
  validates_uniqueness_of :slug, :scope => :site_id

  ## methods ##

  protected

  def normalize_slug
    self.slug = self.name.clone if self.slug.blank? && self.name.present?
    self.slug.slugify!(:without_extension => true, :downcase => true) if self.slug.present?
  end


end
