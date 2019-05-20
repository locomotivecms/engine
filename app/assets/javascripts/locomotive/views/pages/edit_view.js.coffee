#= require ../shared/form_view

Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.EditView extends Locomotive.Views.Pages.FormView

  el: '.main'

  initialize: ->
    super()
    $('#collapsePages').addClass('in')
