class Site  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ## fields ##
  field :name
  field :subdomain, :type => String
  field :domains, :type => Array, :default => []
  
  ## validations ##
  validates_presence_of     :name, :subdomain
  validates_uniqueness_of   :subdomain
  validates_exclusion_of    :subdomain, :in => Locomotive.config.reserved_subdomains
  validates_format_of       :subdomain, :with => Locomotive::Regexps::SUBDOMAIN, :allow_blank => true
  validate                  :domains_must_be_valid_and_unique  
  
  ## callbacks ##
  before_save :add_subdomain_to_domains
  
  ## named scopes ##
  named_scope :match_domain, lambda { |domain| { :where => { :domains => domain } } }
  named_scope :match_domain_with_exclusion_of, lambda { |domain, site| { :where => { :domains => domain, :id.ne => site.id } } }
    
  ## behaviours ##
  add_dirty_methods :domains
  
  ## methods ##
  
  def add_subdomain_to_domains
    self.domains ||= []    
    (self.domains << "#{self.subdomain}.#{Locomotive.config.default_domain}").uniq!
  end
  
  def domains_without_subdomain
    (self.domains || []) - ["#{self.subdomain}.#{Locomotive.config.default_domain}"]
  end
  
  protected
  
  def domains_must_be_valid_and_unique
    return if self.domains.empty? || (!self.new_record? && !self.domains_changed?)
    
    (self.domains_without_subdomain - (self.domains_was || [])) .each do |domain|
      if not self.class.match_domain_with_exclusion_of(domain, self).first.nil?
        self.errors.add(:domains, :domain_taken, :value => domain)
      end
      
      if not domain =~ Locomotive::Regexps::DOMAIN
        self.errors.add(:domains, :invalid_domain, :value => domain)
      end
    end
  end
  
end