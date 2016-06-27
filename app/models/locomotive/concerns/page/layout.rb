module Locomotive
  module Concerns
    module Page
      module Layout

        extend ActiveSupport::Concern

        IS_LAYOUT_REGEX         = /^layouts($|\/)/o.freeze
        EXTENDS_REGEX           = /\{%\s+extends\s/o.freeze
        EXTENDS_PARENT_REGEX    = /\{%\s+extends\s"?parent"?\s%}/o.freeze
        EXTENDS_FULLPATH_REGEX  = /\{%\s+extends\s"?(\S+)"?\s%}/o.freeze
        BLOCK_REGEX             = /\{%\s+block\s/o.freeze


        included do

          ## fields ##
          field :is_layout,     type: Boolean, default: false
          field :allow_layout,  type: Boolean, default: ->{ new_record? }

          ## associations ##
          belongs_to  :layout, class_name: 'Locomotive::Page', inverse_of: :layout_children, validate: false
          has_many    :layout_children, class_name: 'Locomotive::Page', inverse_of: :layout

          ## callbacks ##
          before_validation :valid_allow_layout_consistency
          before_validation :set_raw_template_on_create, if: :new_record?
          before_validation :set_raw_template_on_update, unless: :new_record?

          ## validations ##
          validate :index_can_not_extend_parent

          ## scopes ##
          scope :layouts, -> { where(is_layout: true) }

        end

        def is_layout_or_related?
          !(self.fullpath =~ IS_LAYOUT_REGEX).nil?
        end

        def use_layout?
          !(self.raw_template =~ EXTENDS_REGEX).nil?
        end

        # The layout is also defined in the raw_template. The UI
        # needs it in order to select the layout in the layouts dropdown menu
        def find_layout
          return if !self.allow_layout? || self.layout_id

          if self.raw_template =~ EXTENDS_FULLPATH_REGEX
            # first in the current locale
            if (page = self.site.pages.fullpath($1).first).nil? && !self.site.is_default_locale?(::Mongoid::Fields::I18n.locale)
              # give it a try in the default locale too
              page = self.site.with_default_locale { self.site.pages.fullpath($1).first }
            end

            self.layout_id = page.try(:_id)
          end
        end

        private

        # Even if the allow_layout attribute is true in a first time, we need
        # to make sure the the raw_template includes only the "extends" liquid tag
        # without any other code.
        def valid_allow_layout_consistency
          if allow_layout && raw_template.present? && raw_template =~ EXTENDS_REGEX
            self.allow_layout = (raw_template =~ BLOCK_REGEX).nil?
          end
          true
        end

        def set_raw_template_on_create
          set_raw_template
          true
        end

        def set_raw_template_on_update
          set_raw_template if allow_layout? && layout_id_changed?
          true
        end

        def set_raw_template
          return unless site

          site.with_default_locale do
            if layout_id == 'parent'
              self.raw_template = '{% extends parent %}'
            elsif layout
              self.raw_template = %({% extends "#{self.layout.fullpath}" %})
            elsif raw_template.blank? && !index?
              self.raw_template = '{% extends parent %}'
            end
          end
          # needed it by Steam to get the template from the default locale
          site.each_locale(false) { self.raw_template = '' }
        end

        def index_can_not_extend_parent
          if index? && raw_template =~ EXTENDS_PARENT_REGEX
            self.errors.add(:layout_id, :index_can_not_extend_parent)
          end
        end

      end
    end
  end
end
