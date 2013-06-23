Locomotive.Views.InlineEditor ||= {}

class Locomotive.Views.InlineEditor.ToolbarView extends Backbone.View

  el: '#toolbar .inner'

  events:
    'change .editing-mode input[type=checkbox]':  'toggle_editing_mode'
    'click  .back a':                             'back'
    'click  .element-actions a.save':             'save_changes'
    'click  .element-actions a.cancel':           'cancel_changes'

  render: ->
    super

    @enable_editing_mode_checkbox()

    @enable_content_locale_picker()

    @

  notify: (aloha_editable) ->
    element_id  = aloha_editable.obj.data('element-id')
    @model.get('editable_elements').get(element_id).set
      content: aloha_editable.getContents()

    @$('.element-actions').show()

    @hide_editing_mode_block()

  show_status: (status, growl) ->
    growl ||= false

    message = @$('h1').attr("data-#{status}-status")
    @$('h1').html(message).removeClass().addClass(status)

    $.growl('error', message) if growl

    @

  save_changes: (event) ->
    event.stopPropagation() & event.preventDefault()

    previous_attributes = _.clone @model.attributes

    @model.save {},
      success: (model, response) =>
        model.attributes = previous_attributes
        @$('.element-actions').hide()
        @show_editing_mode_block()
      error: (model, xhr) =>
        @$('.element-actions').hide()

  cancel_changes: (event) ->
    event.stopPropagation() & event.preventDefault()
    @options.target[0].contentWindow.location.href = @options.target[0].contentWindow.location.href

  back: (event) ->
    event.stopPropagation() & event.preventDefault()
    if @model
      window.location.href = @model.get('edit_url')
    else
      window.location.href = window.Locomotive.mounted_on + '/pages'

  show_editing_mode_block: ->
    @$('.editing-mode').show()

  hide_editing_mode_block: ->
    @$('.editing-mode').hide()

  toggle_editing_mode: (event) ->
    return if @editable_elements() == null

    if $(event.target).is(':checked')
      @editable_elements().aloha()
    else
      @editable_elements().removeClass('aloha-editable-highlight').mahalo()

  editable_elements: ->
    if @options.target[0].contentWindow.Aloha
      @options.target[0].contentWindow.Aloha.jQuery('.editable-text')
    else
      null

  enable_editing_mode_checkbox: ->
    @$('.editing-mode input[type=checkbox]').checkToggle
      on_label_color:   '#fff'
      off_label_color:  '#bbb'

  enable_content_locale_picker: ->
    _window = @options.target[0].contentWindow
    link    = @$('#content-locale-picker-link')
    picker  = $('#content-locale-picker')

    return if picker.size() == 0

    link.bind 'click', (event) ->
      event.stopPropagation() & event.preventDefault()
      picker.toggle()

    picker.find('li').bind 'click', (event) =>
      selected  = $(event.target).closest('li')
      locale    = selected.find('span.text').html()

      picker.toggle()

      window.content_locale = locale

      url = @model.get('localized_fullpaths')[locale]
      url = 'index' if url == ''
      url = "/#{url}/_edit"

      _window.location.href = url

  select_locale: (locale) ->
    _window = @options.target[0].contentWindow
    link    = @$('#content-locale-picker-link')
    picker  = $('#content-locale-picker')

    # get the information about the locale
    entry  = picker.find("li[data-locale=#{locale}]")
    image  = entry.find('img').attr('src')
    label  = entry.find('span.text').html()

    # refresh the current entry
    link.find('img').attr('src', image)
    link.find('span.text').html(label)

    # refresh the list of locales
    picker.find('li.selected').removeClass('selected')
    entry.addClass('selected')

  refresh: ->
    @select_locale(@model.get('lang'))

    @$('h1').html(@model.get('title')).removeClass()

    if @$('.editing-mode input[type=checkbox]').is(':checked')
      @$('.editing-mode div.switchArea').trigger('click')

    @$('.element-actions').hide()

    @show_editing_mode_block()


