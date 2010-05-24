class ContentInstance  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # fields ##
  field :name
  
end