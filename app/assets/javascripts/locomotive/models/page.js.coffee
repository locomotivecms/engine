class Locomotive.Models.Page extends Backbone.Model

  paramRoot: 'page'

  urlRoot: "#{Locomotive.mount_on}/pages"

  initialize: ->
    @_normalize()

  _normalize: ->
    @set
      editable_elements: new Locomotive.Models.EditableElementsCollection(@get('editable_elements'))


    # unless _.isArray @get('editable_elements')
    #   console.log('already a collection')
    #   return
    #
    # previous_collection = @previous('editable_elements')
    #
    # console.log(previous_collection)
    #
    # if _.isArray collection
    #   collection = new Locomotive.Models.EditableElementsCollection(@get('editable_elements'))
    # else
    #   collection.fetch(@get('editable_elements'))
    #
    # @set(editable_elements: collection)

    # @set
    #   editable_elements: new Locomotive.Models.EditableElementsCollection(@get('editable_elements'))

  toJSON: ->
    _.tap super, (hash) =>
      hash.editable_elements = @get('editable_elements').toJSONForSave() if @get('editable_elements')

class Locomotive.Models.PagesCollection extends Backbone.Collection