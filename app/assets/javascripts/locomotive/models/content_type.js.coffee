class Locomotive.Models.ContentType extends Backbone.Model

  paramRoot: 'content_type'

  urlRoot: "#{Locomotive.mounted_on}/content_types"

  initialize: ->
    @_normalize()

  _normalize: ->
    fields = @get('entries_custom_fields')
    fields = [] if !fields?

    if _.isArray(fields)
      @set
        entries_custom_fields: new Locomotive.Models.CustomFieldsCollection(fields)

  find_entries_custom_field: (name) ->
    @get('entries_custom_fields').find((field) => field.get('name') == name)

  toJSON: ->
    _.tap super, (hash) =>
      _.each ['label_field_id_text', 'group_by_field_id_text', 'public_submission_accounts_text', 'target_klass_name_text', 'content_type_id_text', 'public_submission_account_emails'], (key) => delete hash[key]
      delete hash.entries_custom_fields
      hash.entries_custom_fields_attributes = @get('entries_custom_fields').toJSONForSave() if @get('entries_custom_fields')? && @get('entries_custom_fields').length > 0

      hash.public_submission_accounts = [''] unless @get('public_submission_accounts')?

class Locomotive.Models.ContentTypesCollection extends Backbone.Collection

  model: Locomotive.Models.ContentType

  url: "#{Locomotive.mounted_on}/content_types"