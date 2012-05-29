#= require ../shared/form_view

Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'change   #page_parent_id':     'change_page_url'
    'click    a#image-picker-link': 'open_image_picker'
    'submit':                       'save'

  initialize: ->
    _.bindAll(@, 'insert_image')

    @model = new Locomotive.Models.Page(@options.page)

    @touched_url = false

    @image_picker_view = new Locomotive.Views.ThemeAssets.ImagePickerView
      collection: new Locomotive.Models.ThemeAssetsCollection()
      on_select:  @insert_image

    @image_picker_view.render()

    Backbone.ModelBinding.bind @

    @editable_elements_view = new Locomotive.Views.EditableElements.EditAllView(collection: @model.get('editable_elements'))

  render: ->
    super()

    # slugify the slug field from title
    @slugify_title()

    # the url gets modified by different ways so reflect the changes in the UI
    @listen_for_url_changes()

    # enable response type
    @enable_response_type_select()

    # enable check boxes
    @enable_templatized_checkbox()

    @enable_redirect_checkbox()

    @enable_other_checkboxes()

    # liquid code textarea
    @enable_liquid_editing()

    # editable elements
    @render_editable_elements()

    return @

  open_image_picker: (event) ->
    event.stopPropagation() & event.preventDefault()
    @image_picker_view.editor = @editor
    @image_picker_view.fetch_assets()

  insert_image: (path) ->
    text = "{{ '#{path}' | theme_image_url }}"
    @editor.replaceSelection(text)
    @image_picker_view.close()

  enable_liquid_editing: ->
    input = @$('#page_raw_template')

    if input.size() > 0
      @editor = CodeMirror.fromTextArea input.get()[0],
        mode:             'liquid'
        autoMatchParens:  false
        lineNumbers:      false
        passDelay:        50
        tabMode:          'shift'
        theme:            'default'
        onChange: (editor) => @model.set(raw_template: editor.getValue())

  after_inputs_fold: ->
    @editor.refresh()

  render_editable_elements: ->
    @$('.formtastic fieldset.inputs:first').before(@editable_elements_view.render().el)
    @editable_elements_view.after_render()

  # Remove the editable elements and rebuild them
  reset_editable_elements: ->
    @editable_elements_view.remove()
    @editable_elements_view.collection = @model.get('editable_elements')
    @render_editable_elements()

  # Just re-connect the model and the views (+ redraw the file fields)
  refresh_editable_elements: ->
    @editable_elements_view.unbind_model()
    @editable_elements_view.collection = @model.get('editable_elements')
    @editable_elements_view.refresh()

  slugify_title: ->
    @$('#page_title').slugify(target: @$('#page_slug'))
    @$('#page_slug').bind 'change', ((event) => @touched_url = true)

  listen_for_url_changes: ->
    setInterval (=> (@change_page_url() & @touched_url = false) if @touched_url), 2000

  change_page_url: ->
    $.rails.ajax
      url:        @$('#page_slug').attr('data-url')
      type:       'get'
      dataType:   'json'
      data:       { parent_id:  @$('#page_parent_id').val(), slug: @$('#page_slug').val() }
      success:    (data) =>
        @$('#page_slug_input .inline-hints').html(data.url).effect('highlight')
        if data.templatized_parent
          @$('li#page_slug_input').show()
          @$('li#page_templatized_input, li#page_target_klass_name_input').hide()
        else
          @$('li#page_templatized_input').show() unless @model.get('redirect')

  enable_response_type_select: ->
    @$('li#page_response_type_input').change (event) =>
      if $(event.target).val() == 'text/html'
        @$('li#page_redirect_input, li#page_redirect_url_input').show()
      else
        @model.set redirect: false
        @$('li#page_redirect_input, li#page_redirect_url_input').hide()

  enable_templatized_checkbox: ->
    @_enable_checkbox 'templatized',
      features:     ['slug', 'redirect', 'listed']
      on_callback:  =>
        @$('li#page_target_klass_name_input').show()
      off_callback: =>
        @$('li#page_target_klass_name_input').hide()

    @$('li#page_templatized_input').hide() if @model.get('templatized_from_parent') == true

  enable_redirect_checkbox: ->
    @_enable_checkbox 'redirect',
      features:     ['templatized', 'cache_strategy']
      on_callback:  =>
        @$('li#page_redirect_url_input').show()
      off_callback: =>
        @$('li#page_redirect_url_input').hide()

  enable_other_checkboxes: ->
    _.each ['published', 'listed'], (exp) =>
      @$('li#page_' + exp + '_input input[type=checkbox]').checkToggle()