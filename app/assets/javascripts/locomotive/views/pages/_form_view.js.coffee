Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.FormView extends Backbone.View

  el: '#content'

  events:
    'keypress #page_title':         'fill_default_slug'
    'keypress #page_slug':          'mark_filled_slug'
    'change   #page_parent_id':     'change_page_url'
    'click    a#image-picker-link': 'open_image_picker'
    'submit':                       'save'

  initialize: ->
    _.bindAll(@, 'insert_image')

    @filled_slug = @touched_url = false
    @image_picker_view = new Locomotive.Views.ThemeAssets.ImagePickerView
      collection: new Locomotive.Models.ThemeAssetsCollection()
      on_select:  @insert_image

  render: ->
    # make title editable (if possible)
    @make_title_editable()

    # the url gets modified by different ways so reflect the changes in the UI
    @listen_for_url_changes()

    # enable check boxes
    @enable_templatized_checkbox()

    @enable_redirect_checkbox()

    @enable_other_checkboxes()

    @_hide_last_separator()

    # liquid code textarea
    @enable_liquid_editing()

    return @

  save: (event) ->
    # by default, follow the default behaviour

  make_title_editable: ->
    title = @$('h2 a.editable')

    if title.size() > 0
      target  = @$("##{title.attr('rel')}")
      target.parent().hide()

      title.click (event) =>
        event.stopPropagation() & event.preventDefault()
        newValue = prompt(title.attr('title'), title.html());
        if newValue && newValue != ''
          title.html(newValue)
          target.val(newValue)

  open_image_picker: (event) ->
    event.stopPropagation() & event.preventDefault()
    @image_picker_view.editor = @editor
    @image_picker_view.render()

  insert_image: (path) ->
    text = "{{ '#{path}' | theme_image_url }}"
    @editor.replaceSelection(text)
    @image_picker_view.close()

  enable_liquid_editing: ->
    @editor = CodeMirror.fromTextArea @$('#page_raw_template').get()[0],
      mode:             'liquid'
      autoMatchParens:  false
      lineNumbers:      false
      passDelay:        50
      tabMode:          'shift'
      theme:            'default'

  fill_default_slug: (event) ->
    unless @filled_slug
      setTimeout (=> @$('#page_slug').val($(event.target).val().slugify('-')) & @touched_url = true), 30

  mark_filled_slug: (event) ->
    @filled_slug = true

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

  enable_templatized_checkbox: ->
    @_enable_checkbox 'templatized',
      features:     ['slug', 'redirect', 'listed']
      on_callback:  =>
        @$('li#page_content_type_id_input').show()
      off_callback: =>
        @$('li#page_content_type_id_input').hide()

  enable_redirect_checkbox: ->
    @_enable_checkbox 'redirect',
      features:     ['templatized', 'cache_strategy']

  enable_other_checkboxes: ->
    _.each ['published', 'listed'], (exp) =>
      @$('li#page_' + exp + '_input input[type=checkbox]').checkToggle()

  _enable_checkbox: (name, options) ->
    @$('li#page_' + name + '_input input[type=checkbox]').checkToggle
      on_callback: =>
        _.each options.features, (exp) -> @$('li#page_' + exp + '_input').hide()
        options.on_callback() if options.on_callback?
        @_hide_last_separator()
      off_callback: =>
        _.each options.features, (exp) -> @$('li#page_' + exp + '_input').show()
        options.off_callback() if options.off_callback?
        @_hide_last_separator()

  _hide_last_separator: ->
    _.each @$('fieldset'), (fieldset) =>
      $(fieldset).find('li.last').removeClass('last')
      $(_.last($(fieldset).find('li.input:visible'))).addClass('last')