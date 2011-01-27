class Site

  include Locomotive::Mongoid::Document

  ## fields ##
  field :name
  field :subdomain
  field :domains, :type => Array, :default => []
  field :meta_keywords
  field :meta_description

  ## associations ##
  references_many :pages
  references_many :snippets, :dependent => :destroy
  references_many :theme_assets, :dependent => :destroy
  references_many :asset_collections, :dependent => :destroy
  references_many :content_types, :dependent => :destroy
  embeds_many :memberships

  ## indexes
  index :domains

  ## validations ##
  validates_presence_of     :name, :subdomain
  validates_uniqueness_of   :subdomain
  validates_exclusion_of    :subdomain, :in => Locomotive.config.reserved_subdomains
  validates_format_of       :subdomain, :with => Locomotive::Regexps::SUBDOMAIN, :allow_blank => true
  validate                  :domains_must_be_valid_and_unique

  ## callbacks ##
  after_create :create_default_pages!
  before_save :add_subdomain_to_domains
  after_destroy :destroy_pages

  ## named scopes ##
  scope :match_domain, lambda { |domain| { :any_in => { :domains => [*domain] } } }
  scope :match_domain_with_exclusion_of, lambda { |domain, site|
    { :any_in => { :domains => [*domain] }, :where => { :_id.ne => site.id } }
  }

  ## methods ##

  def all_pages_in_once
    Page.quick_tree(self)
  end

  def domains=(array)
    array = [] if array.blank?; super(array)
  end

  def accounts
    Account.criteria.in(:_id => self.memberships.collect(&:account_id))
  end

  def admin_memberships
    self.memberships.find_all { |m| m.admin? }
  end

  def add_subdomain_to_domains
    self.domains ||= []
    (self.domains << self.full_subdomain).uniq!
  end

  def domains_without_subdomain
    (self.domains || []) - [self.full_subdomain]
  end

  def domains_with_subdomain
    ((self.domains || []) + [self.full_subdomain]).uniq
  end

  def full_subdomain
    "#{self.subdomain}.#{Locomotive.config.default_domain}"
  end

  def to_liquid
    Locomotive::Liquid::Drops::Site.new(self)
  end

  protected

  def domains_must_be_valid_and_unique
    return if self.domains.empty?

    self.domains_without_subdomain.each do |domain|
      if self.class.match_domain_with_exclusion_of(domain, self).any?
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
        :raw_template => I18n.t("attributes.defaults.pages.#{slug}.body"),
        :published => true
      })
    end
  end

  def destroy_pages
    # pages is a tree so we just need to delete the root (as well as the page not found page)
    self.pages.root.first.try(:destroy) && self.pages.not_found.first.try(:destroy)
  end

end
