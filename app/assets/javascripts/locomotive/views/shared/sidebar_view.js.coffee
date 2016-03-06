Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.SidebarView extends Backbone.View

  el: 'body > .sidebar'

  initialize: ->
    @pages_view = new Locomotive.Views.Pages.ListView()

  render: ->
    @pages_view.render()
    @collapse_in_sections()

  collapse_in_sections: ->
    @$('a[data-toggle="collapse"].is-active').each ->
      target_id = $(this).attr('href')
      $(target_id).collapse('show')


