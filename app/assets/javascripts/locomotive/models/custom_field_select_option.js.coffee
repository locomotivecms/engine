class Locomotive.Models.CustomFieldSelectOption extends Backbone.Model

  toJSONForSave: ->
    _.tap {}, (hash) =>
      for key, value of @.toJSON()
        hash[key] = value unless _.include(['created_at', 'updated_at'], key)

class Locomotive.Models.CustomFieldSelectOptionsCollection extends Backbone.Collection

  model: Locomotive.Models.CustomFieldSelectOption

  toJSONForSave: ->
    @map (model) => model.toJSONForSave()
