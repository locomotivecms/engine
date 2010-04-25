class Page  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ## fields ##
  field :title
  field :path
  field :published, :type => Boolean, :default => false
  field :keywords
  field :description
  
  ## associations ##
  belongs_to_related :site
  embeds_many :parts, :class_name => 'PagePart'
  
  ## validations ##
  validates_presence_of     :site, :title, :path
  validates_uniqueness_of   :path, :scope => :site_id
  validate                  :path_must_not_begin_with_reserverd_keywords
  
  ## callbacks ##
  before_create :add_body_part
  
  ## named scopes ##
  
  ## methods ##
  
  def add_body_part
    self.parts.build :name => 'body', :value => '---body here---'
  end
  
  def path_must_not_begin_with_reserverd_keywords
    if (self.path =~ /^(#{Locomotive.config.forbidden_paths.join('|')})\//) == 0
      errors.add(:path, :reserved_keywords)
    end
  end
end