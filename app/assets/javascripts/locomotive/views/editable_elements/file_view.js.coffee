Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.FileView extends Backbone.View

  tagName: 'li'

  className: 'file input'

  render: ->
    $(@el).html(ich.editable_file_input(@model.toJSON()))

    return @