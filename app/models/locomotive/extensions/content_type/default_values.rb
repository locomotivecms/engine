module Locomotive
  module Extensions
    module ContentType
      module DefaultValues

        extend ActiveSupport::Concern

        included do
          before_save :set_order_by
          before_save :set_label_field
          before_save :set_default_order_by_for_has_many_fields
        end

        protected

        def set_order_by
          unless self.order_by.nil? || %w(created_at updated_at _position).include?(self.order_by)
            field = self.entries_custom_fields.where(:name => self.order_by).first || self.entries_custom_fields.find(self.order_by)

            if field
              self.order_by = field._id
            end
          end

          self.order_by ||= 'created_at'
        end

        def set_label_field
          if @new_label_field_name.present?
            self.label_field_id = self.entries_custom_fields.detect { |f| f.name == @new_label_field_name.underscore }.try(:_id)
          end

          # unknown label_field_name, get the first one instead
          if self.label_field_id.blank?
            self.label_field_id = self.entries_custom_fields.first._id
          end

          field = self.entries_custom_fields.find(self.label_field_id)

          # the label field should always be required
          field.required = true

          self.label_field_name = field.name
        end

        def set_default_order_by_for_has_many_fields
          self.entries_custom_fields.where(:type.in => %w(has_many many_to_many)).each do |field|
            if field.ui_enabled?
              field.order_by = nil
            else
              field.order_by = field.class_name_to_content_type.order_by_definition
            end
          end
        end

      end
    end
  end
end