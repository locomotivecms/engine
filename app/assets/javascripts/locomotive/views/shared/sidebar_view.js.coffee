Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.SidebarView extends Backbone.View

  el: 'body > .sidebar'

  initialize: ->
    _.bindAll(@, 'close_sidebar_on_mobile')

    @pages_view = new Locomotive.Views.Pages.ListView()

    @tokens = [
      PubSub.subscribe 'application_view.resize', @close_sidebar_on_mobile
    ]

  render: ->
    @pages_view.render()
    @collapse_in_sections()
    @close_sidebar_on_mobile()
    @highlight_active_section()

  highlight_active_section: ->
    if section = $(@el).data('current-section')
      @$(".sidebar-link.#{section}").addClass('is-active')

  toggle_sidebar: (event) ->
    if @is_sidebar_open() then @close_sidebar() else @show_sidebar()

  is_sidebar_open: ->
    $('body').hasClass('sidebar-open')

  show_sidebar: ->
    $('body').removeClass('sidebar-closed').addClass('sidebar-open')

  close_sidebar: ->
    $('body').removeClass('sidebar-open').addClass('sidebar-closed')

  close_sidebar_on_mobile: ->
    if @is_sidebar_open() && $(window).width() < 992
      @close_sidebar()

  collapse_in_sections: ->
    @$('a[data-toggle="collapse"].is-active').each ->
      target_id = $(this).attr('href')
      $(target_id).collapse('show')
