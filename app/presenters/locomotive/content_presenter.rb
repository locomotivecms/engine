module Locomotive
  class ContentPresenter < BasePresenter

    # delegate :name, :description, :slug, :order_by, :order_direction, :highlighted_field_name, :group_by_field_name, :api_accounts, :to => :source

    # def contents_custom_fields
    #   self.source.ordered_contents_custom_fields.collect(&:as_json)
    # end
    #
    # def included_methods
    #   super + %w(name description slug order_by order_direction highlighted_field_name group_by_field_name api_accounts contents_custom_fields)
    # end

  end
end