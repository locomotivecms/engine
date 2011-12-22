module Locomotive
  class ContentTypePresenter < BasePresenter

    delegate :name, :description, :slug, :order_by, :order_direction, :highlighted_field_name, :group_by_field_name, :api_accounts, :to => :source

    def entries_custom_fields
      self.source.ordered_entries_custom_fields.collect(&:as_json)
    end

    def included_methods
      super + %w(name description slug order_by order_direction highlighted_field_name group_by_field_name api_accounts entries_custom_fields)
    end

  end
end