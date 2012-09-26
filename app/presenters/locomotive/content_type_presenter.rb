module Locomotive
  class ContentTypePresenter < BasePresenter

    delegate :name, :description, :slug, :order_by, :order_by_attribute, :order_direction, :label_field_name, :group_by_field_id, :raw_item_template, :public_submission_enabled, :to => :source

    delegate :name=, :description=, :slug=, :order_by=, :order_direction=, :label_field_name=, :group_by_field_id=, :raw_item_template=, :public_submission_enabled=, :to => :source

    attr_writer :order_by_attribute, :group_by_field_name

    def set_order_by_attribute
      return unless @order_by_attribute

      if %w{created_at updated_at _position}.include?(@order_by_attribute)
        self.source.order_by = @order_by_attribute
      else
        field = get_field(@order_by_attribute)
        self.source.order_by = field.try(:id)
        self.source.order_by ||= 'created_at'
      end
    end

    def set_group_by_field_name
      return unless @group_by_field_name

      field = get_field(@group_by_field_name)
      self.source.group_by_field_id = field.try(:id)
    end

    def group_by_field_name
      # Get the name of the group_by field in the model
      self.source.entries_custom_fields.find(self.source.group_by_field_id).name
    end

    def entries_custom_fields
      self.source.ordered_entries_custom_fields.collect(&:as_json)
    end

    def entries_custom_fields=(entries_custom_fields)
      fields = entries_custom_fields.collect { |f| filter_entries_custom_field_hash(f) }

      # Update the ones with the same name, and create the new ones
      entries_custom_fields.each do |field|
        name = field['name']
        db_field = self.source.entries_custom_fields.where(:name => name).first if name
        if db_field
          db_field.assign_attributes(field)
        else
          self.source.entries_custom_fields.build(field)
        end
      end
    end

    def klass_name
      self.source.klass_with_custom_fields(:entries).to_s
    end

    def public_submission_account_emails
      self.source.public_submission_accounts.collect do |acct_id|
        acct = Locomotive::Account.find(acct_id)
        acct.email
      end
    end

    def public_submission_account_emails=(emails)
      self.source.public_submission_accounts = emails.collect do |email|
        acct = Locomotive::Account.where(:email => email).first
      end.compact.collect(&:id)
    end

    def included_methods
      super + %w(name description slug order_by order_by_attribute order_direction label_field_name group_by_field_id group_by_field_name raw_item_template public_submission_enabled public_submission_account_emails entries_custom_fields klass_name)
    end

    def included_setters
      super + %w(name description slug order_by order_by_attribute order_direction label_field_name group_by_field_id group_by_field_name raw_item_template public_submission_enabled public_submission_account_emails entries_custom_fields)
    end

    def filter_entries_custom_field_hash(entries_custom_field_hash)
      entries_custom_field_hash.each do |k, v|
        unless custom_fields_write_methods.include? k.to_s
          entries_custom_field_hash.delete(k)
        end
      end
    end

    def custom_fields_write_methods
      %w(hint inverse_of label localized name order_by position required text_formatting type ui_enabled class_name select_options)
    end

    def save
      set_order_by_attribute
      set_group_by_field_name
      super
    end

    protected

    def get_field(name)
      self.source.entries_custom_fields.where(:name => name).first
    end

  end
end
