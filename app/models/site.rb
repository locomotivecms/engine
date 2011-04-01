class Site

  include Locomotive::Mongoid::Document

  ## fields ##
  field :name
  field :meta_keywords
  field :meta_description

  ## associations ##
  references_many :pages
  references_many :snippets, :dependent => :destroy
  references_many :theme_assets, :dependent => :destroy
  references_many :asset_collections, :dependent => :destroy
  references_many :content_types, :dependent => :destroy
  embeds_many :memberships

  ## validations ##
  validates_presence_of     :name

  ## callbacks ##
  after_create :create_default_pages!
  after_destroy :destroy_pages

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
