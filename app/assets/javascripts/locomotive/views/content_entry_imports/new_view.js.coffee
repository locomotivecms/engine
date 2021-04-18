Locomotive.Views.ContentEntryImports ||= {}

class Locomotive.Views.ContentEntryImports.NewView extends Locomotive.Views.Shared.FormView

  el: '.main'

  initialize: ->
    super()
    $('#collapseContentTypes').addClass('in')

  render: ->
    super()