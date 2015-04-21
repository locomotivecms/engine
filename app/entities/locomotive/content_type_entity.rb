module Locomotive
  class ContentTypeEntity < BaseEntity
    expose :name, :slug, :description, :label_field_name,
           :order_by, :order_direction, :order_by_field_name, :group_by_field_id,
           :group_by_field_name, :public_submission_enabled,
           :public_submission_account_emails, :raw_item_template

    expose :entries_custom_fields do |content_type, _|
      list = content_type.ordered_entries_custom_fields
      list ? list.map(&:as_json) : []
    end


  end
end
