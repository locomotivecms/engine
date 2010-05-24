class Site  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  ## fields ##
  field :name
  field :subdomain, :type => String
  field :domains, :type => Array, :default => []
  
  ## associations ##
  has_many_related :pages
  has_many_related :layouts
  has_many_related :snippets
  has_many_related :theme_assets
  has_many_related :asset_collections
  has_many_related :content_types
  embeds_many :memberships
  
  ## validations ##
  validates_presence_of     :name, :subdomain
  validates_uniqueness_of   :subdomain
  validates_exclusion_of    :subdomain, :in => Locomotive.config.reserved_subdomains
  validates_format_of       :subdomain, :with => Locomotive::Regexps::SUBDOMAIN, :allow_blank => true
  validate                  :domains_must_be_valid_and_unique  
  
  ## callbacks ##
  after_create :create_default_pages!
  before_save :add_subdomain_to_domains
  after_destroy :destroy_in_cascade!
  
  ## named scopes ##
  named_scope :match_domain, lambda { |domain| { :where => { :domains => domain } } }
  named_scope :match_domain_with_exclusion_of, lambda { |domain, site| { :where => { :domains => domain, :_id.ne => site.id } } }
    
  ## behaviours ##
  
  ## methods ##

  def accounts
    Account.criteria.in(:_id => self.memberships.collect(&:account_id))
  end
  
  def admin_memberships
    self.memberships.find_all { |m| m.admin? }
  end
  
  def add_subdomain_to_domains
    self.domains ||= []    
    (self.domains << "#{self.subdomain}.#{Locomotive.config.default_domain}").uniq!
  end
  
  def domains_without_subdomain
    (self.domains || []) - ["#{self.subdomain}.#{Locomotive.config.default_domain}"]
  end
  
  def domains_with_subdomain
    ((self.domains || []) + ["#{self.subdomain}.#{Locomotive.config.default_domain}"]).uniq
  end
  
  protected
  
  def domains_must_be_valid_and_unique
    return if self.domains.empty?
            
    self.domains_without_subdomain.each do |domain|
      if not self.class.match_domain_with_exclusion_of(domain, self).empty?
        self.errors.add(:domains, :domain_taken, :value => domain)
      end
      
      if not domain =~ Locomotive::Regexps::DOMAIN
        self.errors.add(:domains, :invalid_domain, :value => domain)
      end
    end
  end
  
  def create_default_pages!
    %w{index 404}.each do |slug|
      self.pages.create({
        :slug => slug, 
        :title => I18n.t("attributes.defaults.pages.#{slug}.title"), 
        :body => I18n.t("attributes.defaults.pages.#{slug}.body")
      })
    end
  end
  
  def destroy_in_cascade!
    %w{pages layouts snippets theme_assets asset_collections content_types}.each do |association|
      self.send(association).destroy_all
    end
  end
  
end