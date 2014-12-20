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

  render: ->
    console.log '[PickerView] rendering'

    @ajaxify()
    @enable_dropzone()

    super

  ajaxify: ->
    for selector in @ajaxified_elements
      $(@el).on 'ajax:success', selector, (event, data, status, xhr) =>
        @$('.updatable').html($(data).find('.updatable').html())

  unajaxify: ->
    for selector in @ajaxified_elements
      $(@el).off 'ajax:success', selector

  select: (event) ->
    console.log '[PickerView] select'
    event.stopPropagation() & event.preventDefault()

    $link = $(event.target)

    alert('TODO')

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
