class Locomotive.Models.CustomField extends Backbone.Model

  initialize: ->
    unless @get('name')?
      @set name: @get('label').slugify()

  toJSONForSave: ->
    _.tap {}, (hash) =>
      for key, value of @.toJSON()
        hash[key] = value unless _.include(['type_text', 'created_at', 'updated_at'], key)

class Locomotive.Models.CustomFieldsCollection extends Backbone.Collection

  model: Locomotive.Models.CustomField

  toJSONForSave: ->
    @map (model) => model.toJSONForSave()
