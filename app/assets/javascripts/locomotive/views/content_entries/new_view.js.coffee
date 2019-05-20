Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.NewView extends Locomotive.Views.Shared.FormView

  el: '.main'

  initialize: ->
    super()
    $('#collapseContentTypes').addClass('in')

  render: ->
    super()

    $('.tab-pane .has-error').each ->
      $tab_pane_id = $(@).parents('.tab-pane').attr('id')
      $tab = $("[href='##{$tab_pane_id}']")
      $tab.addClass('has-errors')
