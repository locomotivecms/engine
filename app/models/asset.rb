class Asset

  include Mongoid::Document
  include Mongoid::Timestamps

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

  %w{image stylesheet javascript pdf media}.each do |type|
    define_method("#{type}?") do
      self.content_type.to_s == type
    end
  end

  def extname
    return nil unless self.source?
    File.extname(self.source_filename).gsub(/^\./, '')
  end

  def to_liquid
    Locomotive::Liquid::Drops::Asset.new(self)
  end

end
