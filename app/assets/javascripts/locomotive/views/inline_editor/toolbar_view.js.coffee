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
    element_id  = aloha_editable.obj.attr('data-element-id')
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
      success: (model, response, xhr) =>
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
    return if (editable_elements = @editable_elements()) == null
    return if (_jQuery = @iframe_jquery()) == null
    
    if $(event.target).is(':checked')
      editable_elements.find('a').each ->
        link = _jQuery(this)
        link.attr('href', link.data('original-url')) if link.data('original-url')
      editable_elements.aloha()
    else
      editable_elements.removeClass('aloha-editable-highlight').mahalo()
      @enhance_iframe_links(editable_elements.find('a'))

  editable_elements: ->
    if _jQuery = @iframe_jquery()
      _jQuery('.editable-long-text, .editable-short-text')
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
      current   = @get_locale_attributes(link)
      selected  = @get_locale_attributes($(event.target).closest('li'))

      @set_locale_attributes(link, selected)
      @set_locale_attributes($(event.target).closest('li'), current)

      picker.toggle()

      window.content_locale = selected[1]

      _window.location.href = '/' + @model.get('localized_fullpaths')[selected[1]] + '/_edit'

  get_locale_attributes: (context) ->
    [context.find('img').attr('src'), context.find('span.text').html()]

  set_locale_attributes: (context, values) ->
    context.find('img').attr('src', values[0])
    context.find('span.text').html(values[1])
  
  enhance_iframe_links: (links) ->
    return if (_jQuery = @iframe_jquery()) == null
    _toolbarView = @
    links.each ->
      link  = _jQuery(this)
      url   = link.attr('href')
      if url? && url.indexOf('#') != 0 && /^(www|http)/.exec(url) == null && /(\/_edit)$/.exec(url) == null && /^\/sites\//.exec(url) == null
        link.data('original-url', url)
        url = '/index' if url == '/'
        modified_url = url
        
        unless url.indexOf('_edit') > 0
          if url.indexOf('?') > 0
            modified_url = url.replace('?', '/_edit?')
          else
            modified_url = "#{url}/_edit"
        
        link.attr('href', modified_url)
        link.bind 'click', ->
          _toolbarView.show_status 'loading'
          window.history.pushState('Object', 'Title', link.attr('href').replace('_edit', '_admin'))

  iframe_jquery: ->
    if @options.target[0].contentWindow.Aloha.jQuery
      @options.target[0].contentWindow.Aloha.jQuery
    else
      null

  refresh: ->
    @$('h1').html(@model.get('title')).removeClass()

    if @$('.editing-mode input[type=checkbox]').is(':checked')
      @$('.editing-mode div.switchArea').trigger('click')

    @$('.element-actions').hide()

    @show_editing_mode_block()
