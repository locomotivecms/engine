class Asset

  include Mongoid::Document
  include Mongoid::Timestamps

  ## extensions ##
  include Extensions::Asset::Types
  include Extensions::Asset::Vignette

  ## fields ##
  field :content_type, :type => String
  field :width, :type => Integer
  field :height, :type => Integer
  field :size, :type => Integer
  field :position, :type => Integer, :default => 0
  mount_uploader :source, AssetUploader

  ## associations ##
  referenced_in :site

  ## validations ##
  validates_presence_of :source

  ## behaviours ##

  ## methods ##

  alias :name :source_filename

  def extname
    return nil unless self.source?
    File.extname(self.source_filename).gsub(/^\./, '')
  end

  def to_liquid
    { :url => self.source.url }.merge(self.attributes).stringify_keys
  end

end
