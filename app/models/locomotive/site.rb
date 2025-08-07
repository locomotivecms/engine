module Locomotive
  class Site

    include Locomotive::Mongoid::Document

    ## Extensions ##
    include Concerns::Shared::Seo
    include Concerns::Site::AccessPoints
    include Concerns::Site::Locales
    include Concerns::Site::Timezone
    include Concerns::Site::Cache
    include Concerns::Site::UrlRedirections
    include Concerns::Site::PrivateAccess
    include Concerns::Site::Metafields
    include Concerns::Site::Sections
    include Concerns::Site::Routes

    ## fields ##
    field :name
    field :robots_txt
    field :maximum_uploaded_file_size, type: ::Integer, default: Locomotive.config.default_maximum_uploaded_file_size
    field :overwrite_same_content_assets, type: Boolean, default: false
    field :allow_dots_in_slugs, type: Boolean, default: false

    mount_uploader :picture, PictureUploader, validate_integrity: true

    ## associations ##
    belongs_to  :created_by,      class_name: 'Locomotive::Account', optional: true
    embeds_many :memberships,     class_name: 'Locomotive::Membership'
    has_many    :pages,           class_name: 'Locomotive::Page',           validate: false, autosave: false
    has_many    :sections,        class_name: 'Locomotive::Section',        dependent: :destroy, validate: false, autosave: false
    has_many    :snippets,        class_name: 'Locomotive::Snippet',        dependent: :destroy, validate: false, autosave: false
    has_many    :theme_assets,    class_name: 'Locomotive::ThemeAsset',     dependent: :destroy, validate: false, autosave: false
    has_many    :content_assets,  class_name: 'Locomotive::ContentAsset',   dependent: :destroy, validate: false, autosave: false
    has_many    :content_types,   class_name: 'Locomotive::ContentType',    dependent: :destroy, validate: false, autosave: false
    has_many    :content_entries, class_name: 'Locomotive::ContentEntry',   dependent: :destroy, validate: false, autosave: false
    has_many    :translations,    class_name: 'Locomotive::Translation',    dependent: :destroy, validate: false, autosave: false
    has_many    :activities,      class_name: 'Locomotive::Activity',       dependent: :destroy, validate: false, autosave: false

    ## validations ##
    validates_presence_of :name

    ## callbacks ##
    after_create        :create_default_pages!
    before_destroy      :destroy_pages

    ## behaviours ##
    accepts_nested_attributes_for :memberships, allow_destroy: true

    ## methods ##

    # Get all the pages in the right order: depth and position, both ASC.
    #
    # @param [ Hash ] conditions Extra conditions passed to the Mongoid criteria
    #
    # @return [ Criteria ] a Mongoid criteria
    #
    def ordered_pages(conditions = {})
      self.pages.unscoped.where(conditions || {}).order_by_depth_and_position
    end

    def localized_content_types
      self.content_types.localized
    end

    def accounts
      Account.criteria.in(_id: self.memberships.map(&:account_id))
    end

    def membership_for(account)
      self.memberships.where(account_id: account._id).first
    end

    def admin_memberships
      self.memberships.find_all { |m| m.admin? }
    end

    def is_admin?(account)
      self.memberships.detect { |m| m.admin? && m.account_id == account._id }
    end

    def to_steam
      repository = Locomotive::Steam::Services.build_instance.repositories.site
      repository.build(self.attributes.dup)
    end

    def to_liquid
      to_steam.to_liquid
    end

    protected

    # FIXME: Currently there is no t/translate method on the I18n module
    # Concerns::Site::I18n which is breaking the testing. The
    # namespaced ::I18n should be changed to just I18n when the t()
    # method is available
    def create_default_pages!
      %w{index 404}.each do |slug|
        page = nil

        self.each_locale do |locale, _|
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
      self.pages.home.first.try(:destroy) && self.pages.not_found.first.try(:destroy)
    end

  end
end
