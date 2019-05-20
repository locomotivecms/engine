Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.IndexView extends Backbone.View

  el: '.main'

  initialize: ->
    @list_view = new Locomotive.Views.Shared.ListView(el: @$('.big-list'))
    @bulk_delete_view = new Locomotive.Views.Shared.BulkDeleteView()
    $('#collapseContentTypes').addClass('in')

  render: ->
    @list_view.render()
    @bulk_delete_view.render()

  remove: ->
    @list_view.remove()
    @bulk_delete_view.remove()
    super()
