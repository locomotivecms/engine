module Locomotive
  module API
    module Entities

      class ContentTypeEntity < BaseEntity

        expose  :name, :slug, :description, :label_field_name, :order_by,
                :order_direction, :group_by_field_id, :public_submission_enabled,
                :raw_item_template

        expose :entries_custom_fields do |content_type, _|
          content_type.ordered_entries_custom_fields || []
        end

        expose :order_by_field_name do |content_type, _|
          value = content_type.order_by
          content_type.find_entries_custom_field(value).try(:name) || value
        end

        expose :group_by_field_name do |content_type, _|
          content_type.group_by_field.try(:name)
        end

        expose :public_submission_account_emails do |content_type, _|
          ([*content_type.public_submission_accounts]).map do |_id|
            Locomotive::Account.where(_id: _id).first.try(:email)
          end.compact
        end

      end

    end
  end
end
