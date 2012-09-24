class Locomotive.Views.ApplicationView extends Backbone.View

  el: 'body'

  render: ->
    @render_flash_messages(@options.flash)

    @add_submenu_behaviours()

    @center_ui_dialog()

    @enable_sites_picker()

    @enable_content_locale_picker()

    # render page view
    if @options.view?
      @view = new @options.view(@options.view_data || {})
      @view.render()

    window.Locomotive.tinyMCE.defaultSettings.language = window.locale # set the default tinyMCE language
    window.Locomotive.tinyMCE.minimalSettings.language = window.locale

    return @

  render_flash_messages: (messages) ->
    _.each messages, (couple) ->
      $.growl couple[0], couple[1]

  center_ui_dialog: ->
    $(window).resize ->
      $('.ui-dialog-content:visible').dialog('option', 'position', 'center')

  add_submenu_behaviours: ->
    $('#submenu ul li.hoverable').each ->
      timer = null
      link  = $(@)
      (popup = link.find('.popup')).removeClass('popup').addClass('submenu-popup'
      ).bind('show', ->
        link.find('a').addClass('hover') & popup.css(
          top:  link.offset().top + link.height() - 2
          left: link.offset().left - parseInt(popup.css('padding-left'))
        ).show()
      ).bind('hide', ->
        link.find('a').removeClass('hover') & $(@).hide()
      ).bind('mouseleave', -> popup.trigger('hide')
      ).bind 'mouseenter', -> clearTimeout(timer)

      $(document.body).append(popup)

      link.hover(
        -> popup.trigger('show')
        -> timer = window.setTimeout (-> popup.trigger('hide')), 30
      )

    css = $('#submenu > ul').attr('class')
    $("#submenu > ul > li.#{css}").addClass('on') if css != ''

  enable_sites_picker: ->
    link    = @$('#sites-picker-link')
    picker  = @$('#sites-picker')

    return if picker.size() == 0

    left = link.position().left + link.parent().position().left - (picker.width() - link.width())
    picker.css('left', left)

    link.bind 'click', (event) ->
      event.stopPropagation() & event.preventDefault()
      picker.toggle()

  enable_content_locale_picker: ->
    link    = @$('#content-locale-picker-link')
    picker  = @$('#content-locale-picker')

    return if picker.size() == 0

    link.bind 'click', (event) ->
      event.stopPropagation() & event.preventDefault()
      picker.toggle()

    picker.find('li').bind 'click', (event) ->
      locale = $(@).attr('data-locale')
      window.addParameterToURL 'content_locale', locale

  unique_dialog_zindex: ->
    # returns the number of jQuery UI modals created in order to set a valid zIndex for each of them.
    # Each modal window should have a different zIndex, otherwise there will be conflicts between them.
    window.Locomotive.jQueryModals ||= 0

    998 + window.Locomotive.jQueryModals++

