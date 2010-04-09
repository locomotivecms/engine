class Site  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ## fields ##
  field :name
  field :domains, :type => Array, :default => []
  
  ## validations ##
  validates_presence_of :name
  validates_length_of :domains, :minimum => 1
  # validates_each :domains, :logic => :domains_are_unique_and_valid
    
  ## behaviours ##
  # timestamps!
  
  ## methods ##
  
  def subdomain=(value)
    return if value.blank?
    (self.domains << "#{value}.#{Locomotive::Configuration.default_domain_name}").uniq!
  end
  
  protected
  
  def domains_are_unique_and_valid
    # self.domains.each do |domain|
    #   self.errors.add(:domains, t())
    # end
  end
  
end