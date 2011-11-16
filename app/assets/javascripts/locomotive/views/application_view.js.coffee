class Locomotive.Views.ApplicationView extends Backbone.View

  el: 'body'

  render: ->
    @render_flash_messages(@options.flash)

    @add_submenu_behaviours()

    @center_ui_dialog()

    if @options.view?
      @view = new @options.view
      @view.render()

    return @

  render_flash_messages: (messages) ->
    _.each messages, (couple) ->
      $.growl couple[0], couple[1]

  center_ui_dialog: ->
    $(window).resize ->
      $('.ui-dialog-content:visible').dialog('option', 'position', 'center')

  add_submenu_behaviours: ->
    # sub menu links
    $('#submenu ul li.hoverable').hover(
      ->
        $(@).find('a').addClass('hover')
        $(@).find('.popup').show()
      ->
        $(@).find('a').removeClass('hover');
        $(@).find('.popup').hide()
    )

    css = $('#submenu > ul').attr('class')
    $("#submenu > ul > li.#{css}").addClass('on') if css != ''

