module Locomotive
  class ContentAsset

    include Locomotive::Mongoid::Document

    ## extensions ##
    include Concerns::Asset::Types
    include Concerns::Asset::Vignette
    include Concerns::Asset::Checksum

    ## fields ##
    field :content_type,  type: String
    field :width,         type: Integer
    field :height,        type: Integer
    field :size,          type: Integer
    field :position,      type: Integer, default: 0

    ## associations ##
    belongs_to :site, class_name: 'Locomotive::Site', validate: false, autosave: false

    ## validations ##
    validates_presence_of :source

    ## behaviours ##
    mount_uploader :source, ContentAssetUploader, mount_on: :source_filename

    ## scopes ##
    scope :ordered, -> { order_by(created_at: :desc) }
    scope :by_filename, ->(query) { where(source_filename: /.*#{query}.*/i) }

    ## methods ##

    alias :name :source_filename

    def extname
      return nil unless self.source? && self.source_filename
      File.extname(self.source_filename).gsub(/^\./, '')
    end

  end
end
