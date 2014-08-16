Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.IndexView extends Backbone.View

  el: '.main'

  initialize: ->
    @list_view = new Locomotive.Views.Shared.ListView(el: @$('.big-list'))

  render: ->
    @list_view.render()

  remove: ->
    @list_view.remove()
    super()