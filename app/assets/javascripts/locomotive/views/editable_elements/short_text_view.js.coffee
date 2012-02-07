Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.ShortTextView extends Backbone.View

  tagName: 'li'

  className: 'text input html'

  render: ->
    $(@el).html(ich.editable_text_input(@model.toJSON()))

    return @

  after_render: ->
    settings = _.extend {}, @tinymce_settings(),
      onchange_callback: (editor) =>
        @model.set(content: editor.getBody().innerHTML)

    @$('textarea').tinymce(settings)

  tinymce_settings: ->
    window.Locomotive.tinyMCE.minimalSettings

  refresh: ->
    # do nothing

  remove: ->
    @$('textarea').tinymce().destroy()
    super