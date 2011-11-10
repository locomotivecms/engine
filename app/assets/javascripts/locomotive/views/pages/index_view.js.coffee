Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.IndexView extends Backbone.View

  el: '#content'

  render: ->
    @index_view = new Locomotive.Views.Pages.ListView()
    @index_view.render()

    return @
