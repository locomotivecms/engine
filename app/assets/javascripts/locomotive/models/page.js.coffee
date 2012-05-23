class Locomotive.Models.Page extends Backbone.Model

  paramRoot: 'page'

  urlRoot: "#{Locomotive.mounted_on}/pages"

  initialize: ->
    @_normalize()

    @set
      edit_url: "#{Locomotive.mounted_on}/pages/#{@id}/edit"

  _normalize: ->
    @set
      editable_elements: new Locomotive.Models.EditableElementsCollection(@get('editable_elements') || [])

  toJSON: ->
    _.tap super, (hash) =>
      _.each ['fullpath', 'localized_fullpaths', 'edit_url', 'parent_id_text', 'response_type_text'], (key) => delete hash[key]

      delete hash['editable_elements']
      hash.editable_elements = @get('editable_elements').toJSONForSave() if @get('editable_elements')? && @get('editable_elements').length > 0

class Locomotive.Models.PagesCollection extends Backbone.Collection
