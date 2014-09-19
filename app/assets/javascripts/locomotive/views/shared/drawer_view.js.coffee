Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.DrawerView extends Backbone.View

  el: 'section.drawer'

  events:
    'click .close-button': 'close'

  open: (url, callback) ->
    container = @$('> .inner')

    if url?
      container.load url, =>
        # @$('.inner .after-scrollable').appendTo($(@el))
        $('body').addClass('drawer-opened')
        callback(container) if callback?
    else
      $('body').addClass('drawer-opened')
      callback(container) if callback?

  close: ->
    $('body').removeClass('drawer-opened')
    # @$('> .after-scrollable').remove()