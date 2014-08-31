Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.DrawerView extends Backbone.View

  el: 'section.drawer'

  events:
    'click .close-button': 'close'

  open: ->
    $('body').addClass('drawer-opened')

  close: ->
    $('body').removeClass('drawer-opened')