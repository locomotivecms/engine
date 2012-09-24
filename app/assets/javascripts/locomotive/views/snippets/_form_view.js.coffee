#= require ../shared/form_view

Locomotive.Views.Snippets ||= {}

class Locomotive.Views.Snippets.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'click    a#image-picker-link': 'open_image_picker'
    'submit':                       'save'

  initialize: ->
    _.bindAll(@, 'insert_image')

    @model = new Locomotive.Models.Snippet(@options.snippet)

    @image_picker_view = new Locomotive.Views.ThemeAssets.ImagePickerView
      collection: new Locomotive.Models.ThemeAssetsCollection()
      on_select:  @insert_image

    @image_picker_view.render()

    Backbone.ModelBinding.bind @

  render: ->
    super()

    # slugify the slug field from name
    @slugify_name()

    # liquid code textarea
    @enable_liquid_editing()

    return @

  slugify_name: ->
    @$('#snippet_name').slugify(target: @$('#snippet_slug'))

  open_image_picker: (event) ->
    event.stopPropagation() & event.preventDefault()
    @image_picker_view.editor = @editor
    @image_picker_view.fetch_assets()

  insert_image: (path) ->
    text = "{{ '#{path}' | theme_image_url }}"
    @editor.replaceSelection(text)
    @image_picker_view.close()

  enable_liquid_editing: ->
    input = @$('#snippet_template')
    @editor = CodeMirror.fromTextArea input.get()[0],
      mode:             'liquid'
      autoMatchParens:  false
      lineNumbers:      false
      passDelay:        50
      tabMode:          'shift'
      theme:            'default medium'
      onChange: (editor) => @model.set(template: editor.getValue())

  after_inputs_fold: ->
    @editor.refresh()