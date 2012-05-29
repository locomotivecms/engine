#= require ../shared/form_view

Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'click    a#image-picker-link': 'open_image_picker'
    'submit': 'save'

  initialize: ->
    _.bindAll(@, 'insert_image')

    @model = new Locomotive.Models.ThemeAsset(@options.theme_asset)

    @image_picker_view = new Locomotive.Views.ThemeAssets.ImagePickerView on_select: @insert_image

    @image_picker_view.render()

    Backbone.ModelBinding.bind @

  render: ->
    super()

    @enable_toggle_between_file_and_text()

    @enable_source_editing()

    @bind_source_mode()

    @enable_source_file()

    return @

  enable_toggle_between_file_and_text: ->
    @$('div.hidden').hide()

    @model.set(performing_plain_text: @$('#theme_asset_performing_plain_text').val())

    @$('.selector > a.alt').click (event) =>
      event.stopPropagation() & event.preventDefault()

      if @$('#file-selector').is(':hidden')
        @$('#text-selector').slideUp 'normal', =>
          @$('#file-selector').slideDown()
          @model.set(performing_plain_text: false)
          @$('input#theme_asset_performing_plain_text').val(false)
      else
        @$('#file-selector').slideUp 'normal', =>
          @$('#text-selector').slideDown 'normal', => @editor.refresh()
          @model.set(performing_plain_text: true)
          @$('#theme_asset_performing_plain_text').val(true)

  enable_source_file: ->
    # only in HTML 5
    @$('.formtastic #theme_asset_source').bind 'change', (event) =>
      input = $(event.target)[0]
      if input.files?
        @model.set(source: input.files[0])

  show_error: (attribute, message, html) ->
    switch attribute
      when 'source'
        @$(if @model.get('performing_plain_text')
          '#theme_asset_plain_text_input .CodeMirror'
        else
          '#theme_asset_source').after(html)
      else super

  open_image_picker: (event) ->
    event.stopPropagation() & event.preventDefault()
    @image_picker_view.editor = @editor
    @image_picker_view.fetch_assets()

  insert_image: (path) ->
    text = "'#{path}'"
    @editor.replaceSelection(text)
    @image_picker_view.close()

  source_mode: ->
    if @model.get('plain_text_type') == 'javascript' then 'javascript' else 'css'

  enable_source_editing: ->
    input   = @$('#theme_asset_plain_text')

    return if input.size() == 0

    @editor = CodeMirror.fromTextArea input.get()[0],
      mode:             @source_mode()
      autoMatchParens:  false
      lineNumbers:      false
      passDelay:        50
      tabMode:          'shift'
      theme:            'default'
      onChange: (editor) => @model.set(plain_text: editor.getValue())

  bind_source_mode: ->
    @$('#theme_asset_plain_text_type').bind 'change', (event) =>
      @editor.setOption 'mode', @source_mode()

  after_inputs_fold: ->
    @editor.refresh() if @editor?