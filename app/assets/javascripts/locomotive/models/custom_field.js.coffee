class Locomotive.Models.CustomField extends Backbone.Model

  initialize: ->
    @_normalize()

    unless @get('name')?
      @set name: @get('label').slugify()

  _normalize: ->
    @set
      select_options: new Locomotive.Models.CustomFieldSelectOptionsCollection(@get('select_options'))

  toJSONForSave: ->
    _.tap {}, (hash) =>
      for key, value of @.toJSON()
        hash[key] = value unless _.include(['select_options', 'type_text', 'text_formatting_text', 'created_at', 'updated_at'], key)
      hash.select_options_attributes = @get('select_options').toJSONForSave() if @get('select_options')

class Locomotive.Models.CustomFieldsCollection extends Backbone.Collection

  model: Locomotive.Models.CustomField

  toJSONForSave: ->
    @map (model) => model.toJSONForSave()
