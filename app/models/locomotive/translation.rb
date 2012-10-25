class Locomotive::Translation
  include Locomotive::Mongoid::Document
  
  belongs_to :site, class_name: "Locomotive::Site"
  field :key
  field :values, type: Hash, default: {}
  
  validates_uniqueness_of :key, scope: :site_id
  validates_presence_of :site
end