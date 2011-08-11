class Site

  include Locomotive::Mongoid::Document

  ## Extensions ##
  extend Extensions::Site::SubdomainDomains
  extend Extensions::Site::FirstInstallation
  include Extensions::Shared::Seo

  ## fields ##
  field :name
  field :robots_txt

  ## associations ##
  references_many :pages, :validate => false
  references_many :snippets, :dependent => :destroy, :validate => false
  references_many :theme_assets, :dependent => :destroy, :validate => false
  references_many :assets, :dependent => :destroy, :validate => false
  references_many :content_types, :dependent => :destroy, :validate => false
  embeds_many :memberships

  ## validations ##
  validates_presence_of :name

  ## callbacks ##
  after_create :create_default_pages!
  after_destroy :destroy_pages

  ## behaviours ##
  enable_subdomain_n_domains_if_multi_sites
  accepts_nested_attributes_for :memberships

  ## methods ##

  def all_pages_in_once
    Page.quick_tree(self)
  end

  def accounts
    Account.criteria.in(:_id => self.memberships.collect(&:account_id))
  end

  def admin_memberships
    self.memberships.find_all { |m| m.admin? }
  end

  def to_liquid
    Locomotive::Liquid::Drops::Site.new(self)
  end

  protected

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
