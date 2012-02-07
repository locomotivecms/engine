class Locomotive.Models.CustomField extends Backbone.Model

  initialize: ->
    @_normalize()

    unless @get('name')?
      @set name: @get('label').slugify()

  _normalize: ->
    @set
      select_options: new Locomotive.Models.CustomFieldSelectOptionsCollection(@get('select_options'))

  _undesired_fields:
    ['select_options', 'type_text', 'text_formatting_text', 'inverse_of_text', 'class_name_text', 'undefined_text', 'undefined', 'created_at', 'updated_at']

  _relationship_fields:
    ['class_name', 'inverse_of', 'ui_enabled']

  is_relationship_type: ->
    _.include(['belongs_to', 'has_many', 'many_to_many'], @get('type'))

  toJSONForSave: ->
    _.tap {}, (hash) =>
      for key, value of @.toJSON()
        unless _.include(@_undesired_fields, key)
          if _.include(@_relationship_fields, key)
            hash[key] = value if @is_relationship_type()
          else
            hash[key] = value

      hash.select_options_attributes = @get('select_options').toJSONForSave() if @get('select_options')? && @get('select_options').length > 0

class Locomotive.Models.CustomFieldsCollection extends Backbone.Collection

  model: Locomotive.Models.CustomField

  toJSONForSave: ->
    @map (model) => model.toJSONForSave()
