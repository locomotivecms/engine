module Locomotive
  class ContentTypePresenter < BasePresenter

    ## properties ##

    properties  :name, :slug

    # must to be declared before the others
    property    :entries_custom_fields, alias: :fields

    property    :description, required: false

    with_options required: false do |presenter|
      presenter.property    :label_field_name
      presenter.properties  :order_by, :order_direction
      presenter.property    :order_by_field_name, only_getter: true
      presenter.properties  :group_by_field_id, :group_by_field_name

      presenter.property    :public_submission_enabled,         type: 'Boolean'
      presenter.property    :public_submission_account_emails,  type: 'Array'

      presenter.property    :raw_item_template
    end

    ## other getters / setters ##

    def entries_custom_fields
      list = self.__source.ordered_entries_custom_fields
      list ? list.map(&:as_json) : []
    end

    def entries_custom_fields=(fields)
      destroyed_fields = []

      fields.each do |attributes|
        id_or_name  = attributes.delete('id') || attributes.delete('_id') || attributes['name']
        field       = self.__source.find_entries_custom_field(id_or_name)

        if field && !!attributes.delete('_destroy')
          destroyed_fields << { _id: field._id, _destroy: true }
          next
        end

        field ||= self.__source.entries_custom_fields.build

        field.from_presenter(attributes)
      end

      # shift to the accepts_nested_attributes function to delete fields
      self.__source.entries_custom_fields_attributes = destroyed_fields
    end

    def order_by_field_name
      value = self.__source.order_by
      self.__source.find_entries_custom_field(value).try(:name) || value
    end

    def group_by_field_name
      self.__source.group_by_field.try(:name)
    end

    def group_by_field_name=(name)
      field = self.__source.find_entries_custom_field(name)
      self.__source.group_by_field_id = field.try(:_id)
    end

    def public_submission_account_emails
      (self.__source.public_submission_accounts || []).collect do |_id|
        Locomotive::Account.where(_id: _id).first.try(:email)
      end.compact
    end

    def public_submission_account_emails=(emails)
      self.__source.public_submission_accounts = emails.collect do |email|
        Locomotive::Account.where(email: email).first
      end.compact.collect(&:id)
    end

    ## methods ##

  end
end
