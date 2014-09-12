Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.DrawerView extends Backbone.View

  el: 'section.drawer'

  events:
    'click .close-button': 'close'

  open: (url) ->
    if url?
      @$('> .inner').load url, =>
        # @$('.inner .after-scrollable').appendTo($(@el))
        $('body').addClass('drawer-opened')
    else
      $('body').addClass('drawer-opened')

  close: ->
    $('body').removeClass('drawer-opened')
    # @$('> .after-scrollable').remove()