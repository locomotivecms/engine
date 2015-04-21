module Locomotive
  module API
    module Forms
      class ContentTypeForm < BaseForm

        attr_accessor :_site

        attrs :name, :slug, :description, :label_field_name,
              :order_by, :order_direction, :group_by_field_id,
              :group_by_field_name, :public_submission_enabled,
              :public_submission_account_emails, :raw_item_template,
              :entries_custom_fields, # alias to entries_custom_fields_attributes
              :entries_custom_fields_attributes

        # @param [ Site ] the current site, or site to scope to
        def initialize(site, attributes = {})
          _site = site
          super(attributes)
        end

        # If the current content type exists, look up the fields and add their IDs
        #  to the attributes hash.  If not, set the entries_custom_fields_attributes
        #  as-is
        def entries_custom_fields=(fields)
          # entries_custom_fields_attributes_will_change!
          self.entries_custom_fields_attributes =
            if existing_content_type.present?
              fields.map do |attrs|
                if field = existing_content_type.find_entries_custom_field(attrs[:name])
                  attrs[:_id] = field._id
                end
                attrs
              end
            else
              fields
            end
        end

        # TODO: figure out what to do without existing_content_type
        def group_by_field_name=(name)
          super
          if existing_content_type.present?
            field = existing_content_type.find_entries_custom_field(name)
            self.group_by_field_id = field.try(:_id)
          end
        end

        # TODO: figure out what to do without existing_content_type
        def public_submission_account_emails=(emails)
          if existing_content_type.present?
            existing_content_type.public_submission_accounts = emails.collect do |email|
              Locomotive::Account.where(email: email).first
            end.compact.collect(&:id)
          end
        end

        private

        def existing_content_type
          @existing_content_type ||= content_type_service.find_by_slug(slug)
        end

        delegate :find_by_slug, to: :content_type_service

        def content_type_service
          @content_type_service ||= ContentTypeService.new(_site)
        end

        def custom_field_finder_service
          @custom_field_finder_service ||= begin
            CustomFieldFinderService.new(existing_content_type)
          end
        end

      end
    end
  end
end
