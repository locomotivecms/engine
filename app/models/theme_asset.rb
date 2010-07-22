class ThemeAsset

  include Locomotive::Mongoid::Document

  ## Extensions ##
  include Models::Extensions::Asset::Vignette

  ## fields ##
  field :slug
  field :content_type
  field :width, :type => Integer
  field :height, :type => Integer
  field :size, :type => Integer
  field :plain_text
  mount_uploader :source, ThemeAssetUploader

  ## associations ##
  belongs_to_related :site

  ## callbacks ##
  before_validation :sanitize_slug
  before_validation :store_plain_text
  before_save     :set_slug

  ## validations ##
  validate :extname_can_not_be_changed
  validates_presence_of :site, :source
  validates_presence_of :slug, :if => Proc.new { |a| a.new_record? && a.performing_plain_text? }
  validates_uniqueness_of :slug, :scope => [:site_id, :content_type]
  validates_integrity_of :source

  ## accessors ##
  attr_accessor :performing_plain_text

  ## methods ##

  %w{movie image stylesheet javascript font}.each do |type|
    define_method("#{type}?") do
      self.content_type == type
    end
  end

  def stylesheet_or_javascript?
    self.stylesheet? || self.javascript?
  end

  def plain_text
    if self.stylesheet_or_javascript?
      self.plain_text = self.source.read if read_attribute(:plain_text).blank?
      read_attribute(:plain_text)
    else
      nil
    end
  end

  def plain_text=(source)
    self.performing_plain_text = true if self.performing_plain_text.nil?
    write_attribute(:plain_text, source)
  end

  def performing_plain_text?
    return true if !self.new_record? && self.stylesheet_or_javascript? && self.errors.empty?

    !(self.performing_plain_text.blank? || self.performing_plain_text == 'false' || self.performing_plain_text == false)
  end

  def store_plain_text
    return if self.plain_text.blank?

    # replace /theme/<content_type>/<slug> occurences by the real amazon S3 url or local files
    sanitized_source = self.plain_text.gsub(/(\/theme\/([a-z]+)\/([a-z_\-0-9]+)\.[a-z]{2,3})/) do |url|
      content_type, slug = url.split('/')[2..-1]

      content_type = content_type.singularize
      slug = slug.split('.').first

      if asset = self.site.theme_assets.where(:content_type => content_type, :slug => slug).first
        asset.source.url
      else
        url
      end
    end

    self.source = CarrierWave::SanitizedFile.new({
      :tempfile => StringIO.new(sanitized_source),
      :filename => "#{self.slug}.#{self.stylesheet? ? 'css' : 'js'}"
    })
  end

  def shortcut_url # ex: /theme/stylesheets/application.css is a shortcut for a theme asset (content_type => stylesheet, slug => 'application')
    File.join('/theme', self.content_type.pluralize, "#{self.slug}#{File.extname(self.source_filename)}")
  rescue
    ''
  end

  def to_liquid
    { :url => self.source.url }.merge(self.attributes)
  end

  protected

  def sanitize_slug
    self.slug.slugify!(:underscore => true) if self.slug.present?
  end

  def set_slug
    if self.slug.blank?
      self.slug = File.basename(self.source_filename, File.extname(self.source_filename))
      self.sanitize_slug
    end
  end

  def extname_can_not_be_changed
    return if self.new_record?

    if File.extname(self.source.file.original_filename) != File.extname(self.source_filename)
      self.errors.add(:source, :extname_changed)
    end
  end
end