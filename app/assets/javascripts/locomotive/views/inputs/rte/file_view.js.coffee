#= require ../../content_assets/picker_view

Locomotive.Views.Inputs.Rte ||= {}

class Locomotive.Views.Inputs.Rte.FileView extends Backbone.View

  opened:
    popover:  false
    picker:   false

  initialize: ->
    _.bindAll(@, 'change_image', 'hide')

    @$link      = $(@el)
    @editor     = @options.editor
    @$popover   = @$link.next('.image-dialog-content')

  render: ->
    @attach_editor()
    @create_popover()

  attach_editor: ->
    command = @editor.toolbar.commandMapping['insertFile:null']
    command.dialog = @

    console.log "[insertFileView] attach_editor"

  create_popover: ->
    @$popover.show()
    @$link.popover
      container:  '.main'
      placement:  'left'
      content:    @$popover
      html:       true
      template:   '<div class="popover" role="tooltip"><div class="arrow"></div><form class="simple_form"><div class="popover-content"></div></form></div>'
    @$link.data('bs.popover').setContent()

    @attach_popover_events()

  attach_popover_events: ->
    @$popover.parents('form').on 'click', '.apply', @change_image
    @$popover.on 'click', '.apply', @change_image
    @$popover.on 'click', '.cancel', @hide

  detach_popover_events: ->
    @$popover.parents('form').on 'click', '.apply', @change_image
    @$popover.on 'click', '.apply', @change_image
    @$popover.on 'click', '.cancel', @hide

  change_image: (event) ->
    @editor.composer.commands.exec 'insertImage',
      src:    @_input_el('src').val()
      class:  @_input_el('alignment', 'select').val()
      title:  @_input_el('title').val()

    @hide()

  show: (state) ->
    console.log "[insertFileView] show #{state}"

    # FIXME (did): if opened without the focus, it will cause an error
    # when executing a command
    @editor.focus()

    if state?
      $image = $(state)
      @_input_el('src').val($image.attr('src'))
      @_input_el('alignment', 'select').val($image.attr('class'))
      @_input_el('title').val($image.attr('title'))

      @show_popover()
    else
      @hide_popover()
      @show_picker()

  show_picker: ->
    if @opened.picker == false
      window.application_view.drawer_view.open(
        @$link.data('url'),
        Locomotive.Views.ContentAssets.PickerView,
        { parent_view: @ })
      @opened.picker = true

  show_popover: ->
    if @opened.popover == false
      @$link.popover('show')
      @opened.popover = true

  hide: ->
    console.log "[insertFileView] hide"
    console.log @opened
    if @opened.picker
      @hide_picker()
    else if @opened.popover
      @hide_popover()

  hide_picker: ->
    console.log "[insertFileView] hide picker"
    window.application_view.drawer_view.close()
    @opened.picker = false

  hide_popover: ->
    @$link.popover('hide')
    @opened.popover = false

  _input_el: (property, type) ->
    type ||= 'input'
    name = "rte_input_image_form[#{property}]"
    @$popover.find("#{type}[name=\"#{name}\"]")

  remove: ->
    console.log "[insertFileView] remove"
    @detach_popover_events()
    @$link.popover('destroy')
    @$('.popover').remove()
    super
