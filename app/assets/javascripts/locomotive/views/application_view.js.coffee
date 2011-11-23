class Locomotive.Views.ApplicationView extends Backbone.View

  el: 'body'

  render: ->
    @render_flash_messages(@options.flash)

    @add_submenu_behaviours()

    @center_ui_dialog()

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
      popup = link.find('.popup').removeClass('popup').addClass('submenu-popup').css(
        top:          link.offset().top + link.height() - 1
        left:         link.offset().left
      ).bind('show', ->
        link.find('a').addClass('hover') & popup.show()
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

