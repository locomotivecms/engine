module Locomotive
  class EditableElement

      include ::Mongoid::Document

      ## fields ##
      field :slug
      field :block
      field :hint
      field :priority,          :type => Integer, :default => 0
      field :fixed,             :type => Boolean, :default => false
      field :disabled,          :type => Boolean, :default => false
      field :from_parent,       :type => Boolean, :default => false
      # field :locales,           :type => Array TODO

      ## associations ##
      embedded_in :page, :class_name => 'Locomotive::Page', :inverse_of => :editable_elements

      ## validations ##
      validates_presence_of :slug

      ## callbacks ##
      after_save :propagate_content, :if => :fixed?

      ## scopes ##
      scope :by_priority, :order_by => [[:priority, :desc]]

      ## methods ##

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
        self.attributes = attributes
      end

      # Copy attributes from an existing editable element coming
      # from the parent page. Each editable element may or not
      # override this method. The source element is a new record.
      #
      # @param [ EditableElement] el The source element
      #
      def copy_attributes_from(el)
        self.attributes   = el.attributes.reject { |attr| !%w(slug block hint priority fixed disabled from_parent).include?(attr) }
        self.from_parent  = true
      end

      protected

      def _selector
        locale = ::Mongoid::Fields::I18n.locale
        {
          'site_id'                         => self.page.site_id,
          "template_dependencies.#{locale}" => { '$in' => [self.page._id] },
          'editable_elements.fixed'         => true,
          'editable_elements.block'         => self.block,
          'editable_elements.slug'          => self.slug
        }
      end

      def propagate_content
        # needs to be overridden for each kind of elements (file, short text, ...etc)
        true
      end

  end
end