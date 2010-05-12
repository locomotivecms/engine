class Asset
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ## fields ##
  field :name, :type => String
  field :content_type, :type => String
  field :width, :type => Integer
  field :height, :type => Integer
  field :size, :type => Integer
  field :position, :type => Integer, :default => 0
  mount_uploader :source, AssetUploader
    
  ## associations ##
  embedded_in :collection, :class_name => 'AssetCollection', :inverse_of => :assets
  
  ## validations ##
  validates_presence_of :name, :source
  
  ## methods ##
  
  %w{image stylesheet javascript pdf video audio}.each do |type|
    define_method("#{type}?") do
      self.content_type == type
    end  
  end
  
end