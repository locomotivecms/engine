Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.NewView extends Locomotive.Views.Pages.FormView

  el: '.main'

  initialize: ->
    super()
    $('#collapsePages').addClass('in')
