Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.SelectView extends Backbone.View

  tagName: 'li'

  className: 'select input'

  render: ->
    $(@el).html(ich.editable_select_input(@model.toJSON()))
    Backbone.ModelBinding.bind(this, { select: "data-model-attr" });
    return @

  after_render: ->
    # do nothing
 
  refresh: ->
    # do nothing


