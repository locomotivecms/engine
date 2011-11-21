class Locomotive.Models.Page extends Backbone.Model

  initialize: ->
    @set
      editable_elements: new Locomotive.Models.EditableElementsCollection(@get('editable_elements'))

class Locomotive.Models.PagesCollection extends Backbone.Collection