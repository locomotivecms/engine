module Locomotive
  class EditableElement

    include Locomotive::Mongoid::Document

    ## fields ##
    field :slug
    field :block
    field :content,     localize: true
    field :hint
    field :priority,    type: Integer, default: 0
    field :fixed,       type: Boolean, default: false
    field :disabled,    type: Boolean, default: false, localize: true
    field :from_parent, type: Boolean, default: false
    field :locales,     type: Array,   default: []

    ## associations ##
    embedded_in :page, class_name: 'Locomotive::Page', inverse_of: :editable_elements

    ## validations ##
    validates_presence_of :slug

    ## callbacks ##

    ## scopes ##
    scope :by_priority,         -> { order_by(priority: :desc) }
    scope :by_block_and_slug,   ->(block, slug) { where(block: block, slug: slug) }

    ## methods ##

    def disabled?
      !!self.disabled # the original method does not work quite well with the localization
    end

    def _type
      nil
    end

    def page_id
      self._parent.try(:_id)
    end

    def humanized_id
      [self.block, self.slug].compact.join('_').gsub('/', '_')
    end

    # Make sure the current locale is added to the list
    # of locales for the current element so that we know
    # in which languages the element was translated.
    #
    def add_current_locale
      locale = ::Mongoid::Fields::I18n.locale.to_s
      self.locales << locale unless self.locales.include?(locale)
    end

  end
end
