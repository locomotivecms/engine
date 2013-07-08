module Locomotive
  class EditableElement

    # include ::Mongoid::Document
    include Locomotive::Mongoid::Document

    ## fields ##
    field :slug
    field :block
    field :hint
    field :priority,          type: Integer, default: 0
    field :fixed,             type: Boolean, default: false
    field :disabled,          type: Boolean, default: false, localize: true
    field :from_parent,       type: Boolean, default: false
    field :locales,           type: Array,   default: []

    ## associations ##
    embedded_in :page, class_name: 'Locomotive::Page', inverse_of: :editable_elements

    ## validations ##
    validates_presence_of :slug

    ## callbacks ##
    after_save :propagate_content, if: :fixed?

    ## scopes ##
    scope :by_priority, order_by(priority: :desc)

    ## methods ##

    def disabled?
      !!self.disabled # the original method does not work quite well with the localization
    end

    def disabled_in_all_translations?
      return self.disabled_translations if self.disabled_translations.is_a?(Boolean)
      self.disabled_translations.all? { |_, v| v == true }
    end

    # Determines if the current element can be edited in the back-office
    #
    def editable?
      !self.disabled? &&
      self.locales.include?(::Mongoid::Fields::I18n.locale.to_s) &&
      (!self.fixed? || !self.from_parent?) &&
      !self.destroyed?
    end

    def _run_rearrange_callbacks
      # callback from page/tree. not needed in the editable elements
    end

    def default_content?
      # needs to be overridden for each kind of elements
      true
    end

    # Copy attributes extracted from the corresponding Liquid tag
    # Each editable element overrides this method.
    #
    # @param [ Hash ] attributes The up-to-date attributes
    #
    def copy_attributes(attributes)
      # _type is among the mass-assign protected attributes.
      if type = attributes.delete(:_type)
        self._type = type
      end

      self.attributes = attributes
    end

    # Copy attributes from an existing editable element coming
    # from the parent page. Each type of an editable element may or not
    # override this method. The source element is a new record.
    #
    # @param [ EditableElement] el The source element
    #
    def copy_attributes_from(el)
      self.attributes   = el.attributes.reject { |attr| !%w(slug block hint priority fixed disabled locales from_parent).include?(attr) }
      self.from_parent  = true
    end

    # Copy the default attributes: _type, hint, fixed, priority and locales
    # from an existing editable element coming from the parent page.
    # Each type of an editable element may or not override this method for
    # options for instance.
    #
    # @param [ EditableElement] el The source element
    #
    def copy_default_attributes_from(el)
      # only the type, hint and fixed properties can be modified from the element
      %w(_type hint fixed priority locales).each do |attr|
        self.send(:"#{attr}=", el.send(attr.to_sym))
      end
    end

    # Set the default content from an existing editable element coming
    # from the parent page. Each editable element may or not
    # override this method. The source element is an existing record.
    def set_default_content_from(el)
      self.add_current_locale
    end

    # Make sure the current locale is added to the list
    # of locales for the current element so that we know
    # in which languages the element was translated.
    #
    def add_current_locale
      locale = ::Mongoid::Fields::I18n.locale.to_s
      self.locales << locale unless self.locales.include?(locale)
    end

    # Set the content of the editable element with a default value
    # only if the content has not already been modified by the user.
    #
    # @param [ String ] content The default content.
    #
    def content_from_default=(content)
      # needs to be overridden for each kind of elements
    end

    protected

    def _selector
      locale = ::Mongoid::Fields::I18n.locale
      {
        'site_id'                         => self.page.site_id,
        "template_dependencies.#{locale}" => { '$in' => [self.page._id] },
        'editable_elements.fixed'         => true,
        'editable_elements.block'         => self.block,
        'editable_elements.slug'          => self.slug,
      }
    end

    # Update the value (or content) of the elements matching the same block/slug
    # as the current element in all the pages inheriting from the current page.
    # This method is called only if the element has the "fixed" property set to true.
    # It also needs to be overridden for each kind of elements (file, short text, ...etc)
    #
    def propagate_content
      true
    end

  end
end
