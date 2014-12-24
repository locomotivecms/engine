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

    $link   = $(event.target)
    title   = $link.attr('title')
    url     = $link.attr('href')

    if $link.data('image')
      @editor.composer.commands.exec 'insertImage',
        src:    url
        title:  title
    else
      html = "<a href='#{url}' title='#{title}'>#{title}</a>"
      @editor.composer.commands.exec 'insertHTML', html

    @options.parent_view.hide()

  open_edit_drawer: (event) ->
    console.log '[PickerView] open_edit_drawer'
    event.stopPropagation() & event.preventDefault()

    $link = $(event.target)

    window.application_view.drawer_view.open($link.attr('href'), Locomotive.Views.ContentAssets.EditView)

  enable_dropzone: ->
    @dropzone = new Locomotive.Views.ContentAssets.DropzoneView(el: @$('.dropzone-container')).render()

  remove: ->
    console.log '[PickerView] remove'

    # we might need to re-open this view further
    if @options.parent_view
      @options.parent_view.opened.picker = false

    @unajaxify()
    @dropzone.remove()

    super
