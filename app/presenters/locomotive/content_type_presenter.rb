module Locomotive
  class ContentTypePresenter < BasePresenter

    ## properties ##

    properties :name, :description, :slug, :raw_item_template

    collection :entries_custom_fields, :alias => :fields # must to be declared before the others

    property   :label_field_name
    properties :order_by, :order_direction
    property   :order_by_field_name, :only_getter => true
    properties :group_by_field_id, :group_by_field_name
    properties :public_submission_enabled, :public_submission_account_emails

    ## other getters / setters ##

    def entries_custom_fields=(fields)
      destroyed_fields = []

      fields.each do |attributes|
        id_or_name  = attributes.delete('id') || attributes.delete('_id') || attributes['name']
        field       = self.source.find_entries_custom_field(id_or_name)

        if field && !!attributes.delete('_destroy')
          destroyed_fields << { :_id => field._id, :_destroy => true }
          next
        end

        field ||= self.source.entries_custom_fields.build

        field.from_presenter(attributes)
      end

      # shift to the accepts_nested_attributes function to delete fields
      self.source.entries_custom_fields_attributes = destroyed_fields
    end

    def order_by_field_name
      value = self.source.order_by
      self.source.find_entries_custom_field(value).try(:name) || value
    end

    def group_by_field_name
      self.source.group_by_field.try(:name)
    end

    def group_by_field_name=(name)
      field = self.source.find_entries_custom_field(name)
      self.source.group_by_field_id = field.try(:_id)
    end

    def public_submission_account_emails
      (self.source.public_submission_accounts || []).collect do |_id|
        Locomotive::Account.find(_id).email
      end
    end

    def public_submission_account_emails=(emails)
      self.source.public_submission_accounts = emails.collect do |email|
        Locomotive::Account.where(:email => email).first
      end.compact.collect(&:id)
    end

    ## methods ##

  end
end
