Locomotive.Views.Translations ||= {}

class Locomotive.Views.Translations.IndexView extends Backbone.View

  el: '.main'

  initialize: ->
    @bulk_delete_view = new Locomotive.Views.Shared.BulkDeleteView()

  render: ->
    @bulk_delete_view.render()
