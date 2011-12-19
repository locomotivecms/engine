class Locomotive.Models.ContentType extends Backbone.Model

  paramRoot: 'content_type'

  urlRoot: "#{Locomotive.mount_on}/content_types"

  initialize: ->
    @_normalize()

  _normalize: ->
    @set
      contents_custom_fields: new Locomotive.Models.CustomFieldsCollection(@get('contents_custom_fields'))

  toJSON: ->
    _.tap super, (hash) =>
      hash.contents_custom_fields = @get('contents_custom_fields').toJSONForSave() if @get('contents_custom_fields')

class Locomotive.Models.ContentTypesCollection extends Backbone.Collection

  model: Locomotive.Models.ContentType

  url: "#{Locomotive.mount_on}/content_types"