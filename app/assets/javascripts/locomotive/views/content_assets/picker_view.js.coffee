#= require ./edit_view
#= require ./dropzone_view

Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.PickerView extends Backbone.View

  events:
    'click a.select': 'select'
    'click a.edit':   'open_edit_drawer'

  ajaxified_elements: [
    '.nav-tabs a',
    '.pagination a',
    '.search-bar form',
    '.asset a.remove',
    'a.refresh'
  ]

  initialize: ->
    @editor = @options.parent_view.editor

  render: ->
    console.log '[PickerView] rendering'

    @ajaxify()
    @enable_dropzone()
    @create_image_popover()

    super

  ajaxify: ->
    for selector in @ajaxified_elements
      $(@el).on 'ajax:success', selector, (event, data, status, xhr) =>
        @$('.updatable').html($(data).find('.updatable').html())

  unajaxify: ->
    for selector in @ajaxified_elements
      $(@el).off 'ajax:success', selector

  create_image_popover: ->
    @$image_popover = @$('.image-dialog-content')
    @$content.show()
    @$link.popover
      container:  '.drawer'
      placement:  'left'
      content:    @$content
      html:       true
      template:   '<div class="popover" role="tooltip"><div class="arrow"></div><form class="simple_form"><div class="popover-content"></div></form></div>'
    @$link.data('bs.popover').setContent()


  select: (event) ->
    console.log '[PickerView] select'
    event.stopPropagation() & event.preventDefault()

    $link = $(event.target)

    @editor.composer.commands.exec 'insertImage', $link.attr('href')
    @options.parent_view.hide()
    # src:   $link.attr('href')

  open_edit_drawer: (event) ->
    console.log '[PickerView] open_edit_drawer'
    event.stopPropagation() & event.preventDefault()

    $link = $(event.target)

    window.application_view.drawer_view.open($link.attr('href'), Locomotive.Views.ContentAssets.EditView)

  enable_dropzone: ->
    @dropzone = new Locomotive.Views.ContentAssets.DropzoneView(el: @$('.dropzone-container')).render()

  remove: ->
    console.log '[PickerView] remove'

    @unajaxify()
    @dropzone.remove()

    super
