class Locomotive.Views.ApplicationView extends Backbone.View

  el: 'body'

  events:
    'click .navbar .navbar-toggle': 'slide_sidebar'

  initialize: ->
    @header_view  = new Locomotive.Views.Shared.HeaderView()
    @sidebar_view = new Locomotive.Views.Shared.SidebarView()
    @drawer_view  = new Locomotive.Views.Shared.DrawerView()

  render: ->
    @render_flash_messages(@options.flash)

    @sidebar_view.render()
    @drawer_view.render()

    @set_max_height()

    @automatic_max_height()

    # render page view
    if @options.view?
      @view = new @options.view(@options.view_data || {})
      @view.render()

    return @

  slide_sidebar: (event) ->
    $('body').toggleClass('slide-right-sidebar')

  render_flash_messages: (messages) ->
    _.each messages, (couple) ->
      Locomotive.notify couple[1], couple[0]

  automatic_max_height: ->
    $(window).on 'resize', =>
      height = @set_max_height()
      PubSub.publish 'application_view.resize', height: height

  set_max_height: ->
    max_height  = $(window).height()
    height      = max_height - @header_view.height()

    @$('> .wrapper').height(height)

    height
