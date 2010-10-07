class ThemeAsset

  include Locomotive::Mongoid::Document

  ## fields ##
  field :local_path
  field :content_type
  field :width, :type => Integer
  field :height, :type => Integer
  field :size, :type => Integer
  # field :plain_text
  field :folder, :default => nil
  field :hidden, :type => Boolean, :default => false
  mount_uploader :source, ThemeAssetUploader

  ## associations ##
  referenced_in :site

  ## indexes ##
  index :site_id
  index [[:site_id, Mongo::ASCENDING], [:local_path, Mongo::ASCENDING]]

  ## callbacks ##
  before_validation :store_plain_text
  before_validation :sanitize_folder
  before_validation :build_local_path
  # before_validation :sanitize_slug
  # before_validation :escape_shortcut_urls
  # before_save :set_slug

  ## validations ##
  # validate :extname_can_not_be_changed
  validates_presence_of :site, :source
  # validate :plain_text_name_is_required_if_no_given_source
  validates_presence_of :plain_text_name, :if => Proc.new { |a| a.performing_plain_text? }
  # validates_presence_of :slug, :if => Proc.new { |a| a.new_record? && a.performing_plain_text? }
  # validates_uniqueness_of :slug, :scope => [:site_id, :content_type, :folder]
  validates_uniqueness_of :local_path, :scope => :site_id
  validates_integrity_of :source

  ## named scopes ##
  scope :visible, :where => { :hidden => false }

  ## accessors ##
  attr_accessor :plain_text_name, :plain_text, :performing_plain_text

  ## methods ##

  # def source=(new_file)
  #   @new_source = true
  #   super
  # end

  %w{movie image stylesheet javascript font}.each do |type|
    define_method("#{type}?") do
      self.content_type == type
    end
  end

  def stylesheet_or_javascript?
    self.stylesheet? || self.javascript?
  end

  def plain_text_name
    if not @plain_text_name_changed
      @plain_text_name ||= self.safe_source_filename
    end
    @plain_text_name.gsub(/(\.[a-z0-9A-Z]+)$/, '') rescue nil
    #
    # @plain_text_name ||= self.safe_source_filename rescue nil if
    #
    # if @plain_text_name_changed
    #
    #
    # @plain_text_name_changed ? @plain_text_name :
    # (@plain_text_name || self.safe_source_filename).gsub(/(\.[a-z0-9A-Z]+)$/, '') rescue nil
  end

  def plain_text_name=(name)
    @plain_text_name_changed = true
    @plain_text_name = name
  end

  def plain_text
    if not @plain_text_changed
      @plain_text ||= self.source.read rescue nil
    end
    @plain_text
    #   # self.plain_text = self.source.read if read_attribute(:plain_text).blank?
    #   # read_attribute(:plain_text)
    # else
    #   nil
    # end
  end

  def plain_text=(source)
    # @new_source = true
    @plain_text_changed = true
    self.performing_plain_text = true #if self.performing_plain_text.nil?
    @plain_text = source
    # write_attribute(:plain_text, source)
  end

  def performing_plain_text?
    Boolean.set(self.performing_plain_text)
    # self.performing_plain_text == true || self.performing_plain_text == '1' || self.performing_plain_text ==
    # return true if !self.new_record? && self.stylesheet_or_javascript? && self.errors.empty?
    # !(self.performing_plain_text.blank? || self.performing_plain_text == 'false' || self.performing_plain_text == false)
  end

  def store_plain_text
    return if !self.stylesheet_or_javascript? || self.plain_text_name.blank? || self.plain_text.blank?

    sanitized_source = self.escape_shortcut_urls(self.plain_text)

    self.source = CarrierWave::SanitizedFile.new({
      :tempfile => StringIO.new(sanitized_source),
      :filename => "#{self.plain_text_name}.#{self.stylesheet? ? 'css' : 'js'}"
    })
  end

  # def shortcut_url # ex: /stylesheets/application.css is a shortcut for a theme asset (content_type => stylesheet, slug => 'application')
  #   File.join(self.content_type.pluralize, "#{self.slug}#{File.extname(self.source_filename)}")
  # rescue
  #   ''
  # end

  def to_liquid
    { :url => self.source.url }.merge(self.attributes)
  end

  protected

  # def new_source?
  #   @new_source == true
  # end

  def safe_source_filename
    self.source_filename || self.source.send(:original_filename) rescue nil
  end

  def sanitize_folder
    self.folder = self.content_type.pluralize if self.folder.blank?

    # no accents, no spaces, no leading and ending trails
    self.folder = ActiveSupport::Inflector.transliterate(self.folder).gsub(/(\s)+/, '_').gsub(/^\//, '').gsub(/\/$/, '')

    # folder should begin by a root folder
    if (self.folder =~ /^(stylesheets|javascripts|images|media|fonts)/).nil?
      self.folder = File.join(self.content_type.pluralize, self.folder)
    end
  end

  def build_local_path
    puts "self.source_filename = #{self.source_filename} / #{self.safe_source_filename} / #{File.join(self.folder, self.safe_source_filename)}"
    self.local_path = File.join(self.folder, self.safe_source_filename)
  end

  def escape_shortcut_urls(text)
    return if text.blank?

    text.gsub(/[("'](\/(stylesheets|javascripts|images|media)\/((.+)\/)*([a-z_\-0-9]+)\.[a-z]{2,3})[)"']/) do |path|
      sanitized_path = path.gsub(/[("')]/, '').gsub(/^\//, '')

      # puts "\t\t\tfound path = #{sanitized_path}"

      if asset = self.site.theme_assets.where(:local_path => sanitized_path).first
        "#{path.first}#{asset.source.url}#{path.last}"
      else
        path
      end

      # content_type, slug = url.split('/')[1..-1]

      # content_type = content_type.singularize
      # slug = slug.split('.').first

      # if asset = self.site.theme_assets.where(:content_type => content_type, :slug => slug).first
        # asset.source.url
      # else
        # url
      # end
    end
  end

  # def plain_text_name_is_required_if_no_given_source
  #   puts "@performing_plain_text = #{self.performing_plain_text?} / #{@plain_text_name} / new_file = #{self.source.inspect}"
  #   if self.performing_plain_text? && @plain_text_name.blank?
  #     self.errors.add(:plain_text_name, :blank)
  #   end
  # end

  # def sanitize_slug
  #   self.slug.parameterize! if self.slug.present?
  # end
  #
  # def set_slug
  #   if self.slug.blank?
  #     self.slug = File.basename(self.source_filename, File.extname(self.source_filename))
  #     self.sanitize_slug
  #   end
  # end
  #
  # def extname_can_not_be_changed
  #   return if self.new_record? || self.source.file.original_filename.nil?
  #
  #   puts "filename => #{self.source_filename} / source file => #{self.source.file.inspect}"
  #
  #   if File.extname(self.source.file.original_filename) != File.extname(self.source_filename)
  #     self.errors.add(:source, :extname_changed)
  #   end
  # end
end
