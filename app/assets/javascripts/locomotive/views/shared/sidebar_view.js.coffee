Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.SidebarView extends Backbone.View

  el: 'nav.sidebar'

  initialize: ->
    @pages_view = new Locomotive.Views.Pages.ListView()

  render: ->
    @pages_view.render()