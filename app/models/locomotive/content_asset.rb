module Locomotive
  class ContentAsset

    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    ## extensions ##
    include Extensions::Asset::Types
    include Extensions::Asset::Vignette

    ## fields ##
    field :content_type,  :type => String
    field :width,         :type => Integer
    field :height,        :type => Integer
    field :size,          :type => Integer
    field :position,      :type => Integer, :default => 0

    ## associations ##
    belongs_to :site, :class_name => 'Locomotive::Site'

    ## validations ##
    validates_presence_of :source

    ## behaviours ##
    mount_uploader :source, ContentAssetUploader, :mount_on => :source_filename

    ## methods ##

    alias :name :source_filename

    def extname
      return nil unless self.source?
      File.extname(self.source_filename).gsub(/^\./, '')
    end

    def to_liquid
      { :url => self.source.url }.merge(self.attributes).stringify_keys
    end

    def as_json(options = {})
      Locomotive::ContentAssetPresenter.new(self).as_json
    end

  end
end