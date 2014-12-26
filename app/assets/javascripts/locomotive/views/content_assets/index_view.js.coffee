#= require ./dropzone_view

Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.IndexView extends Backbone.View

  el: '.main'

  events:
    'click .header-row a.upload': 'open_file_browser'

  initialize: ->
    _.bindAll(@, 'set_sidebar_max_height')
    @dropzone = new Locomotive.Views.ContentAssets.DropzoneView(el: @$('.dropzone'))

  render: ->
    @dropzone.render()
    @automatic_sidebar_max_height()
    @set_sidebar_max_height()
    super

  open_file_browser: (event) ->
    @dropzone.open_file_browser(event)

  automatic_sidebar_max_height: ->
    $(window).on 'resize', @set_sidebar_max_height

  set_sidebar_max_height: ->
    main_height = $(@el).height()
    max_height  = @$('.content-assets').height()
    max_height  = main_height if main_height > max_height
    $(@dropzone.el).height(max_height)

  remove: ->
    $(window).off 'resize', @set_sidebar_max_height
    @dropzone.remove()
