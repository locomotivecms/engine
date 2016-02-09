#= require ./dropzone_view
#= require ./index_view

Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.IndexView extends Backbone.View

  el: '.main'

  events:
    'click .header-row a.upload': 'open_file_browser'
    'click a.edit':               'open_edit_drawer'

  initialize: ->
    _.bindAll(@, 'set_sidebar_max_height')
    @refresh_url = @$('.content-assets').data('refresh-url')
    @dropzone = new Locomotive.Views.ContentAssets.DropzoneView(el: @$('.dropzone'))

  render: ->
    @dropzone.render()
    @automatic_sidebar_max_height()
    @set_sidebar_max_height()
    super

  open_edit_drawer: (event) ->
    # console.log '[IndexView] open_edit_drawer'
    event.stopPropagation() & event.preventDefault()

    $link = $(event.target)

    window.application_view.drawer_view.open(
      $link.attr('href'),
      Locomotive.Views.ContentAssets.EditImageView,
      {
        on_apply_callback: (data) =>
          window.location.href = @refresh_url
      })

  hide_from_drawer: (stack_size) ->
    # console.log '[IndexView] hide_from_drawer'
    # we might need to re-open this view further
    if @options.parent_view && stack_size == 0
      @options.parent_view.opened.picker = false

  open_file_browser: (event) ->
    @dropzone.open_file_browser(event)

  automatic_sidebar_max_height: ->
    $(window).on 'resize', @set_sidebar_max_height

  set_sidebar_max_height: ->
    setTimeout ( =>
      main_height = $(@el).height()
      max_height  = @$('.content-assets').height()
      # max_height  = @$('.main-assets').height()
      max_height  = main_height if main_height > max_height

      console.log main_height

      $(@dropzone.el).height(max_height)
    ), 20

  remove: ->
    $(window).off 'resize', @set_sidebar_max_height
    @dropzone.remove()
