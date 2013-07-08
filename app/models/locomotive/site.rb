module Locomotive
  class Site

    include Locomotive::Mongoid::Document

    ## Extensions ##
    extend  Extensions::Site::SubdomainDomains
    extend  Extensions::Site::FirstInstallation
    include Extensions::Shared::Seo
    include Extensions::Site::Locales
    include Extensions::Site::Timezone

    ## fields ##
    field :name
    field :robots_txt

    ## associations ##
    has_many    :pages,           class_name: 'Locomotive::Page',           validate: false, autosave: false
    has_many    :snippets,        class_name: 'Locomotive::Snippet',        dependent: :destroy, validate: false, autosave: false
    has_many    :theme_assets,    class_name: 'Locomotive::ThemeAsset',     dependent: :destroy, validate: false, autosave: false
    has_many    :content_assets,  class_name: 'Locomotive::ContentAsset',   dependent: :destroy, validate: false, autosave: false
    has_many    :content_types,   class_name: 'Locomotive::ContentType',    dependent: :destroy, validate: false, autosave: false
    has_many    :content_entries, class_name: 'Locomotive::ContentEntry',   dependent: :destroy, validate: false, autosave: false
    has_many    :translations,    class_name: 'Locomotive::Translation',    dependent: :destroy, validate: false, autosave: false
    embeds_many :memberships,     class_name: 'Locomotive::Membership'

    ## validations ##
    validates_presence_of :name

    ## callbacks ##
    after_create    :create_default_pages!
    after_destroy   :destroy_pages

    ## behaviours ##
    enable_subdomain_n_domains_if_multi_sites
    accepts_nested_attributes_for :memberships, allow_destroy: true

    ## methods ##

    def all_pages_in_once
      Page.quick_tree(self)
    end

    def fetch_page(path, logged_in)
      Locomotive::Page.fetch_page_from_path self, path, logged_in
    end

    def accounts
      Account.criteria.in(_id: self.memberships.map(&:account_id))
    end

    def admin_memberships
      self.memberships.find_all { |m| m.admin? }
    end

    def is_admin?(account)
      self.memberships.detect { |m| m.admin? && m.account_id == account._id }
    end

    protected

    # FIXME: Currently there is no t/translate method on the I18n module
    # Extensions::Site::I18n which is breaking the testing. The
    # namespaced ::I18n should be changed to just I18n when the t()
    # method is available
    def create_default_pages!
      %w{index 404}.each do |slug|
        page = nil

        self.each_locale do |locale|
          page ||= self.pages.build(published: true) # first locale = default one

          page.attributes = {
            slug:         slug,
            title:        ::I18n.t("attributes.defaults.pages.#{slug}.title", locale: locale),
            raw_template: ::I18n.t("attributes.defaults.pages.#{slug}.body", locale: locale)
          }
        end

        self.with_default_locale { page.save! }
      end

    end

    def destroy_pages
      # pages is a tree so we just need to delete the root (as well as the page not found page)
      self.pages.root.first.try(:destroy) && self.pages.not_found.first.try(:destroy)
    end

  end
end
