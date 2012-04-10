module Locomotive
  class Page

    include Locomotive::Mongoid::Document

    ## Extensions ##
    include Extensions::Page::Tree
    include Extensions::Page::EditableElements
    include Extensions::Page::Parse
    include Extensions::Page::Render
    include Extensions::Page::Templatized
    include Extensions::Page::Redirect
    include Extensions::Page::Listed
    include Extensions::Shared::Seo

    ## fields ##
    field :title,               :localize => true
    field :slug,                :localize => true
    field :fullpath,            :localize => true
    field :handle
    field :raw_template,        :localize => true
    field :locales,             :type => Array
    field :published,           :type => Boolean, :default => false
    field :cache_strategy,      :default => 'none'
    field :response_type,       :default => 'text/html'

    ## associations ##
    belongs_to :site, :class_name => 'Locomotive::Site'

    ## indexes ##
    index :site_id
    index :parent_id
    index [[:fullpath, Mongo::ASCENDING], [:site_id, Mongo::ASCENDING]]

    ## callbacks ##
    after_initialize    :set_default_raw_template
    before_validation   :normalize_slug
    before_save         :build_fullpath
    before_save         :record_current_locale
    before_destroy      :do_not_remove_index_and_404_pages

    ## validations ##
    validates_presence_of     :site, :title, :slug
    validates_uniqueness_of   :slug, :scope => [:site_id, :parent_id]
    validates_uniqueness_of   :handle, :allow_blank => true
    validates_exclusion_of    :slug, :in => Locomotive.config.reserved_slugs, :if => Proc.new { |p| p.depth <= 1 }

    ## named scopes ##
    scope :latest_updated,      :order_by => [[:updated_at, :desc]], :limit => Locomotive.config.ui[:latest_entries_nb]
    scope :root,                :where => { :slug => 'index', :depth => 0 }
    scope :not_found,           :where => { :slug => '404', :depth => 0 }
    scope :published,           :where => { :published => true }
    scope :fullpath,            lambda { |fullpath| { :where => { :fullpath => fullpath } } }
    scope :handle,              lambda { |handle| { :where => { :handle => handle } } }
    scope :minimal_attributes,  lambda { |attrs = []| { :only => (attrs || []) + %w(title slug fullpath position depth published templatized redirect listed response_type parent_id parent_ids site_id created_at updated_at) } }
    scope :dependent_from,      lambda { |id| { :where => { :template_dependencies.in => [id] } } }

    ## methods ##

    def index?
      self.slug == 'index' && self.depth.to_i == 0
    end

    def not_found?
      self.slug == '404' && self.depth.to_i == 0
    end

    def index_or_not_found?
      self.index? || self.not_found?
    end

    def with_cache?
      self.cache_strategy != 'none'
    end

    def default_response_type?
      self.response_type == 'text/html'
    end

    def translated?
      self.title_translations.key?(::Mongoid::Fields::I18n.locale.to_s) rescue false
    end

    def to_liquid
      Locomotive::Liquid::Drops::Page.new(self)
    end

    def to_presenter
      Locomotive::PagePresenter.new(self)
    end

    def as_json(options = {})
      self.to_presenter.as_json
    end

    protected

    def do_not_remove_index_and_404_pages
      return if self.site.nil? || self.site.destroyed?

      if self.index? || self.not_found?
        self.errors[:base] << ::I18n.t('errors.messages.protected_page')
      end

      self.errors.empty?
    end

    def normalize_slug
      self.slug = self.title.clone if self.slug.blank? && self.title.present?
      self.slug.permalink! if self.slug.present?
    end

    def set_default_raw_template
      self.raw_template ||= ::I18n.t('attributes.defaults.pages.other.body')
    end

    def build_fullpath
      if self.index? || self.not_found?
        self.fullpath = self.slug
      else
        slugs = self.ancestors_and_self.map(&:slug)
        slugs.shift unless slugs.size == 1
        self.fullpath = File.join slugs.compact
      end
    end

    def record_current_locale
      self.locales ||= []
      self.locales << ::Mongoid::Fields::I18n.locale
      self.locales.uniq!
    end

  end
end
