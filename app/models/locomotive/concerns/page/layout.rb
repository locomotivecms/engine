module Locomotive
  module Concerns
    module Page
      module Layout

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :is_layout,     type: Boolean, default: false
          field :allow_layout,  type: Boolean, default: ->{ new_record? }

          ## associations ##
          belongs_to  :layout, class_name: 'Locomotive::Page', inverse_of: :layout_children, validate: false
          has_many    :layout_children, class_name: 'Locomotive::Page', inverse_of: :layout

          ## callbacks ##
          before_validation :set_default_raw_template

          ## scopes ##
          scope :layouts, -> { where(is_layout: true) }

        end

        def is_layout_or_related?
          !(self.fullpath =~ /^layouts($|\/)/).nil?
        end

        private

        def set_default_raw_template
          if self.allow_layout?
            set_default_raw_template_if_layout
          else
            set_default_raw_template_if_no_layout
          end
        end

        def set_default_raw_template_if_layout
          if self.layout
            self.raw_template = %({% extends "#{self.layout.fullpath}" %})
          elsif self.layout_id_was
            # use case: layout -> no layout
            self.raw_template = nil # FIXME: not sure about that
          end
        end

        def set_default_raw_template_if_no_layout
          return true if self.raw_template.present?

          self.raw_template = if self.index? || !self.site.is_default_locale?(::Mongoid::Fields::I18n.locale.to_s)
            ''
          else
            "{% extends 'parent' %}"
          end
        end

      end
    end
  end
end
