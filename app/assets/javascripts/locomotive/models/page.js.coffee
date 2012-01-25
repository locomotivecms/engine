class Locomotive.Models.Page extends Backbone.Model

  paramRoot: 'page'

  urlRoot: "#{Locomotive.mounted_on}/pages"

  initialize: ->
    @_normalize()

    @set
      edit_url: "#{Locomotive.mounted_on}/pages/#{@id}/edit"

  _normalize: ->
    @set
      editable_elements: new Locomotive.Models.EditableElementsCollection(@get('editable_elements'))

  toJSON: ->
    _.tap super, (hash) =>
      hash.editable_elements = @get('editable_elements').toJSONForSave() if @get('editable_elements')

class Locomotive.Models.PagesCollection extends Backbone.Collection