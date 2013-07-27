Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.TextView extends Backbone.View

  tagName: 'li'

  className: 'text input html'

  default_line_height: 20

  render: ->
    $(@el).html(ich.editable_text_input(@model.toJSON()))

    return @

  after_render: ->
    if @model.get('format') == 'html'
      @$('textarea').tinymce(@tinymce_settings())
    else
      @$('textarea').bind 'keyup', (event) =>
        input = $(event.target)
        @model.set(content: input.val())

  tinymce_settings: ->
    base_settings = window.Locomotive.tinyMCE.defaultSettings

    if @model.get('line_break') == false
      base_settings = window.Locomotive.tinyMCE.minimalSettings

    _.extend {}, base_settings,
      height:   @model.get('rows') * @default_line_height
      oninit:   ((editor) =>
          $.cmd 'S', (() =>
            @model.set(content: editor.getContent())
            $(@el).parents('form').trigger('submit')
          ), [], ignoreCase: true, document: editor.dom.doc),
      onchange_callback: (editor) =>
        @model.set(content: editor.getContent())

  refresh: ->
    # do nothing

  remove: ->
    if @model.get('format') == 'html'
      @$('textarea').tinymce().remove()

    super