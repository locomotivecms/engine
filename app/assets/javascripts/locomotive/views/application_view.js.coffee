#= require ./simple_view

class Locomotive.Views.ApplicationView extends Locomotive.Views.SimpleView

  el: 'body'

  events:
    'click .navbar .navbar-toggle': 'slide_sidebar'

  initialize: ->
    @header_view  = new Locomotive.Views.Shared.HeaderView()
    @sidebar_view = new Locomotive.Views.Shared.SidebarView()
    @drawer_view  = new Locomotive.Views.Shared.DrawerView()

  render: ->
    super

    @sidebar_view.render()
    @drawer_view.render()

    @set_max_height()

    @automatic_max_height()

  slide_sidebar: (event) ->
    $('body').toggleClass('slide-right-sidebar')

  automatic_max_height: ->
    $(window).on 'resize', =>
      height = @set_max_height()
      PubSub.publish 'application_view.resize', height: height

  set_max_height: ->
    max_height  = $(window).height()
    height      = max_height - @header_view.height()

    @$('> .wrapper').height(height)

    height
