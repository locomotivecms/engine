module Locomotive
  class ContentTypePresenter < BasePresenter

    delegate :name, :description, :slug, :order_by, :order_direction, :label_field_name, :group_by_field_id, :raw_item_template, :public_submission_enabled, :public_submission_accounts, :to => :source

    delegate :name=, :description=, :slug=, :order_by=, :order_direction=, :label_field_name=, :group_by_field_id=, :raw_item_template=, :public_submission_enabled=, :public_submission_accounts=, :to => :source

    def entries_custom_fields
      self.source.ordered_entries_custom_fields.collect(&:as_json)
    end

    def entries_custom_fields=(entries_custom_fields)
      fields = entries_custom_fields.collect { |f| filter_entries_custom_field_hash(f) }
      self.source.entries_custom_fields = fields
    end

    def klass_name
      self.source.klass_with_custom_fields(:entries).to_s
    end

    def included_methods
      super + %w(name description slug order_by order_direction label_field_name group_by_field_id public_submission_accounts entries_custom_fields klass_name)
    end

    def filter_entries_custom_field_hash(entries_custom_field_hash)
      entries_custom_field_hash.each do |k, v|
        unless custom_fields_write_methods.include? k.to_s
          entries_custom_field_hash.delete(k)
        end
      end
    end

    def custom_fields_write_methods
      %w(hint inverse_of label localized name order_by position required text_formatting type ui_enabled class_name)
    end

  end
end
