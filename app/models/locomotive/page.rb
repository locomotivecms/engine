module Locomotive
  class Page

    include Locomotive::Mongoid::Document

    MINIMAL_ATTRIBUTES = %w(_id title slug fullpath position depth published templatized target_klass_name redirect listed response_type parent_id parent_ids site_id created_at updated_at raw_template is_layout)

    ## concerns ##
    include Concerns::Shared::SiteScope
    include Concerns::Shared::Userstamp
    include Concerns::Shared::Slug
    include Concerns::Shared::Seo
    include Concerns::Page::Tree
    include Concerns::Page::EditableElements
    include Concerns::Page::Layout
    include Concerns::Page::Templatized
    include Concerns::Page::Redirect
    include Concerns::Page::Listed
    include Concerns::Page::ToSteam
    include Concerns::Page::Sections

    ## fields ##
    field :title,               localize: true
    field :slug,                localize: true
    field :fullpath,            localize: true
    field :handle
    field :raw_template,        localize: true
    field :locales,             type: Array
    field :published,           type: Boolean, default: false
    field :cache_enabled,       type: Boolean, default: true
    field :cache_control
    field :cache_vary
    field :response_type,       default: 'text/html'
    field :display_settings,    type: Hash

    ## indexes ##
    index parent_id: 1
    index site_id: 1, handle: 1
    index site_id: 1, fullpath: 1
    index site_id: 1, updated_at: 1

    ## behaviours ##
    slugify_from        :title

    ## callbacks ##
    before_create       :localize_default_attributes
    before_create       :build_fullpath
    before_update       :build_fullpath, unless: :skip_callbacks_on_update
    before_save         :record_current_locale, unless: :skip_callbacks_on_update
    after_save          :update_children, unless: :skip_callbacks_on_update

    ## validations ##
    validates_presence_of     :title, :slug
    validates_uniqueness_of   :slug,    scope: [:site_id, :parent_id], allow_blank: true
    validates_uniqueness_of   :handle,  scope: :site_id, allow_blank: true
    validates_exclusion_of    :slug,    in: Locomotive.config.reserved_slugs, if: Proc.new { |p| p.depth <= 1 }

    ## named scopes ##
    scope :latest_updated,      -> { order_by(updated_at: :desc).limit(Locomotive.config.ui[:latest_entries_nb]) }
    scope :home,                -> { where(slug: 'index', depth: 0) }
    scope :not_found,           -> { where(slug: '404', depth: 0) }
    scope :published,           -> { where(published: true) }
    scope :fullpath,            ->(fullpath) { where(fullpath: fullpath) }
    scope :handle,              ->(handle) { where(handle: handle) }
    scope :minimal_attributes,  -> { without(:raw_template, :template) }
    scope :dependent_from,      ->(id) { where(:template_dependencies.in => [id]) }
    scope :by_id_or_fullpath,   ->(id_or_fullpath) { any_of({ _id: id_or_fullpath }, { fullpath: id_or_fullpath }) }

    delegate :fullpath, to: :parent, prefix: true

    attr_accessor :skip_callbacks_on_update

    ## methods ##

    def index?
      self.slug == 'index' && self.depth.to_i == 0
    end

    def not_found?
      self.slug == '404' && self.depth.to_i == 0
    end

    def unpublished?
      !self.published?
    end

    def index_or_not_found?
      self.index? || self.not_found?
    end

    def default_response_type?
      self.response_type == 'text/html'
    end

    def translated?
      self.title_translations.key?(::Mongoid::Fields::I18n.locale.to_s) rescue false
    end

    def translated_in
      self.title_translations.try(:keys)
    end

    def hidden?
      (self.display_settings || {})['hidden'] || false
    end

    def update_without_validation_and_callback!
      self.updating_descendants = true
      self.save(validate: false)
      self.updating_descendants = false
    end

    def touch_site_attribute
      self.raw_template_previously_changed? ? :template_version : :content_version
    end

    protected

    # The title and slug of a new page should be the same in all
    # the locales of a site.
    def localize_default_attributes
      _title, _slug = self.title, self.slug

      self.site.each_locale(false) do |locale, _|
        self.title, self.slug = _title, _slug
      end
    end

    def build_fullpath
      if self.index_or_not_found?
        self.site.each_locale { |locale, current| self.fullpath = self.slug }
      else
        _parent = self.parent # do not hit the database more than once

        self.site.each_locale do |locale, current|
          # if the page has been already persisted, we don't need to update the fullpath
          # in the locales other than in the current one.
          next if self.persisted? && !current

          parent_fullpath = self.depth == 1 ? nil : _parent.try(:fullpath)

          self.fullpath = [parent_fullpath, self.slug].compact.join('/')
        end
      end
    end

    def update_children
      self.children.map(&:save) if self.slug_previously_changed? or self.fullpath_previously_changed?
    end

    def record_current_locale
      self.locales ||= []
      self.locales << ::Mongoid::Fields::I18n.locale
      self.locales.uniq!
    end

  end
end
