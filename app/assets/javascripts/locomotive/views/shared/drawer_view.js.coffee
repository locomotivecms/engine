Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.DrawerView extends Backbone.View

  el: 'section.drawer'

  events:
    'click .close-button': 'close'

  open: (url, callback, close_callback) ->
    console.log "[DrawerView] open, opened = #{$('body').hasClass('drawer-opened')}, #{url}"

    container = @$('> .inner').html('<div></div>').find('> div')

    if url?
      @_close_callback = close_callback if close_callback?

      container.load url, =>
        # @$('.inner .after-scrollable').appendTo($(@el))
        $('body').addClass('drawer-opened')
        callback(container) if callback?
    else
      $('body').addClass('drawer-opened')
      callback(container) if callback?

  close: ->
    $('body').removeClass('drawer-opened')

    setTimeout @_close_callback, 500 if @_close_callback?

    # @_close_callback()
    # @$('> .after-scrollable').remove()