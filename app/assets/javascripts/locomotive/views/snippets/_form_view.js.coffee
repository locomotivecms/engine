#= require ../shared/form_view

Locomotive.Views.Snippets ||= {}

class Locomotive.Views.Snippets.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'click a#image-picker-link':   'open_image_picker'
    'click a#copy-template-link':  'replace_template'
    'submit':                      'save'

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
    @$('#snippet_name').slugify
      target:     @$('#snippet_slug')
      url:        window.permalink_service_url

  open_image_picker: (event) ->
    event.stopPropagation() & event.preventDefault()
    @image_picker_view.editor = @editor
    @image_picker_view.fetch_assets()

  insert_image: (path) ->
    text = "{{ '#{path}' | theme_image_url }}"
    @editor.replaceSelection(text)
    @image_picker_view.close()

  replace_template: (event) ->
    event.stopPropagation() & event.preventDefault()

    link = $(event.target).closest('a')

    $.rails.ajax
      url:       link.attr('href')
      type:      'get'
      dataType:  'json'
      success:  (data) =>
        @editor.setValue(data.template)

  enable_liquid_editing: ->
    input = @$('#snippet_template')
    @editor = CodeMirror.fromTextArea input.get()[0],
      mode:             'liquid'
      autoMatchParens:  false
      lineNumbers:      false
      passDelay:        50
      tabMode:          'shift'
      theme:            'default medium'

    @editor.on 'change', (editor, change) => @model.set(template: editor.getValue())

  after_inputs_fold: ->
    @editor.refresh()