module Locomotive
  module API
    module Forms

      class ContentTypeForm < BaseForm

        attr_accessor :site

        attrs :name, :slug, :description, :label_field_name,
              :order_by, :order_direction, :group_by,
              :public_submission_enabled,
              :public_submission_accounts,
              :public_submission_title_template,
              :entry_template,
              :entries_custom_fields_attributes,
              :display_settings,
              :filter_fields

        # @param [ Site ] the current site, or site to scope to
        def initialize(site, attributes = {})
          self.site = site
          super(attributes)
        end

        # If the current content type exists, look up the fields and add their IDs
        # to the attributes hash.  If not, set the entries_custom_fields_attributes
        # as-is
        def fields=(fields)
          self.entries_custom_fields_attributes = fields.map do |attrs|
            if field = existing_content_type.try(:find_entries_custom_field, attrs[:name])
              attrs[:_id] = field._id
            end

            ContentTypeFieldForm.new(content_type_service, field, attrs).serializable_hash
          end
        end

        def public_submission_account_emails=(emails)
          self.public_submission_accounts = emails.collect do |email|
            Locomotive::Account.where(email: email).first
          end.compact.map(&:id)
        end

        # deprecated
        def raw_item_template=(template)
          set_attribute(:entry_template, template)
        end

        def order_by=(field)
          field = '_position' if field == 'manually'
          set_attribute(:order_by, field)
        end

        def display_settings=(settings)
          (settings || {}).each do |k, v|
            if k == 'position'
              settings[k] = v.to_i
            else
              settings[k] = v == 'true'
            end
          end
          set_attribute(:display_settings, settings)
        end

        private

        def existing_content_type
          @existing_content_type ||= content_type_service.find_by_slug(slug).first
        end

        def content_type_service
          @content_type_service ||= ContentTypeService.new(self.site)
        end

      end

    end
  end
end
