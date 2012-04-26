module Locomotive
  class Site

    include Locomotive::Mongoid::Document

    ## Extensions ##
    extend  Extensions::Site::SubdomainDomains
    extend  Extensions::Site::FirstInstallation
    include Extensions::Shared::Seo
    include Extensions::Site::Locales

    ## fields ##
    field :name
    field :robots_txt

    ## associations ##
    references_many :pages,           :class_name => 'Locomotive::Page',          :validate => false
    references_many :snippets,        :class_name => 'Locomotive::Snippet',       :dependent => :destroy, :validate => false
    references_many :theme_assets,    :class_name => 'Locomotive::ThemeAsset',    :dependent => :destroy, :validate => false
    references_many :content_assets,  :class_name => 'Locomotive::ContentAsset',  :dependent => :destroy, :validate => false
    references_many :content_types,   :class_name => 'Locomotive::ContentType',   :dependent => :destroy, :validate => false
    embeds_many     :memberships,     :class_name => 'Locomotive::Membership'

    ## validations ##
    validates_presence_of :name

    ## callbacks ##
    after_create    :create_default_pages!
    after_destroy   :destroy_pages

    ## behaviours ##
    enable_subdomain_n_domains_if_multi_sites
    accepts_nested_attributes_for :memberships, :allow_destroy => true

    ## methods ##

    def all_pages_in_once
      Page.quick_tree(self)
    end

    def fetch_page(path, logged_in)
      Locomotive::Page.fetch_page_from_path self, path, logged_in
    end

    def accounts
      Account.criteria.in(:_id => self.memberships.map(&:account_id))
    end

    def admin_memberships
      self.memberships.find_all { |m| m.admin? }
    end

    def to_liquid
      Locomotive::Liquid::Drops::Site.new(self)
    end

    def to_presenter(options = {})
      Locomotive::SitePresenter.new(self, options)
    end

    def as_json(options = {})
      self.to_presenter(options).as_json
    end

    protected

    # FIXME: Currently there is no t/translate method on the I18n module
    # Extensions::Site::I18n which is breaking the testing. The
    # namespaced ::I18n should be changed to just I18n when the t()
    # method is available
    def create_default_pages!
      ::Mongoid::Fields::I18n.with_locale(self.default_locale) do
        %w{index 404}.each do |slug|
          self.pages.create({
            :slug         => slug,
            :title        => ::I18n.t("attributes.defaults.pages.#{slug}.title"),
            :raw_template => ::I18n.t("attributes.defaults.pages.#{slug}.body"),
            :published    => true
          })
        end
      end
    end

    def destroy_pages
      # pages is a tree so we just need to delete the root (as well as the page not found page)
      self.pages.root.first.try(:destroy) && self.pages.not_found.first.try(:destroy)
    end

  end
end