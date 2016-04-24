module Locomotive
  module API
    module Entities

      class ContentTypeEntity < BaseEntity

        expose  :name, :slug, :description, :label_field_name, :order_direction,
                :public_submission_enabled,
                :public_submission_accounts,
                :public_submission_title_template,
                :entry_template, :display_settings, :filter_fields

        expose :fields, using: ContentTypeFieldEntity do |content_type, _|
          content_type.ordered_entries_custom_fields || []
        end

        expose :order_by do |content_type, _|
          content_type.order_by_attribute
        end

        expose :group_by do |content_type, _|
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
