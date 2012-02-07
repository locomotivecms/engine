class Locomotive.Models.ContentType extends Backbone.Model

  paramRoot: 'content_type'

  urlRoot: "#{Locomotive.mounted_on}/content_types"

  initialize: ->
    @_normalize()

  _normalize: ->
    @set
      entries_custom_fields: new Locomotive.Models.CustomFieldsCollection(@get('entries_custom_fields'))

  toJSON: ->
    _.tap super, (hash) =>
      delete hash.entries_custom_fields
      hash.entries_custom_fields_attributes = @get('entries_custom_fields').toJSONForSave() if @get('entries_custom_fields')? && @get('entries_custom_fields').length > 0

class Locomotive.Models.ContentTypesCollection extends Backbone.Collection

  model: Locomotive.Models.ContentType

  url: "#{Locomotive.mounted_on}/content_types"