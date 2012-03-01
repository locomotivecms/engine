module Locomotive
  class ContentTypePresenter < BasePresenter

    delegate :name, :description, :slug, :order_by, :order_direction, :label_field_name, :group_by_field_id, :public_submission_accounts, :to => :source

    def entries_custom_fields
      self.source.ordered_entries_custom_fields.collect(&:as_json)
    end

    def klass_name
      self.source.klass_with_custom_fields(:entries).to_s
    end

    def included_methods
      super + %w(name description slug order_by order_direction label_field_name group_by_field_id public_submission_accounts entries_custom_fields klass_name)
    end

  end
end