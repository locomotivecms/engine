Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.ShortTextView extends Backbone.View

  tagName: 'li'

  className: 'text input html'

  render: ->
    $(@el).html(ich.editable_text_input(@model.toJSON()))

    @$('textarea').tinymce window.Locomotive.tinyMCE.minimalSettings

    return @