module Locomotive
  module Extensions
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
          before_validation :set_default_raw_template_if_layout

          ## scopes ##
          scope :layouts, where(is_layout: true)

        end

        private

        def set_default_raw_template_if_layout
          return true unless self.allow_layout?

          if self.layout
            self.raw_template = %({% extends "#{self.layout.fullpath}" %})
          elsif self.layout_id_was
            # use case: layout -> no layout
            self.raw_template = nil
          end
        end

      end
    end
  end
end
