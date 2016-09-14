#= require ../../content_assets/picker_view

Locomotive.Views.Inputs.Rte ||= {}

class Locomotive.Views.Inputs.Rte.FileView extends Backbone.View

  opened:
    popover:  false
    picker:   false

  container:
    dataset:
      showdialogonselection: true

  initialize: ->
    _.bindAll(@, 'change_image', 'insert_file', 'hide')

    @$link        = @$('a[data-wysihtml5-command=insertFile]')
    @editor       = @options.editor
    @$popover     = @$link.next('.image-dialog-content')

    @pubsub_token = PubSub.subscribe('file_picker.select', @insert_file)

  render: ->
    @attach_editor()
    @create_popover()

  attach_editor: ->
    command = @editor.toolbar.commandMapping['insertFile:null']
    command.dialog = @

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
      alt:    @_input_el('alt').val()

    @hide()

  insert_file: (msg, data) ->
    return unless data.parent_view.cid == @.cid

    if data.image
      @editor.composer.commands.exec 'insertImage',
        src:    data.url
        title:  data.title
        alt:    data.alt
    else
      html = "<a href='#{data.url}' title='#{data.title}'>#{data.title}</a>"
      @editor.composer.commands.exec 'insertHTML', html

    @editor.toolbar._preventInstantFocus()

    @hide()

  show: (state) ->
    # console.log "[insertFileView] show #{state} / #{state?}"

    # FIXME (did): if opened without the focus, it will cause an error
    # when executing a command
    @editor.focus()

    if state == false
      @hide_popover()
      @show_picker()
    else
      $image = $(state)
      @_input_el('src').val($image.attr('src'))
      @_input_el('alignment', 'select').val($image.attr('class'))
      @_input_el('title').val($image.attr('title'))
      @_input_el('alt').val($image.attr('alt'))

      @show_popover()

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

  update: (state) ->
    # do nothing

  hide: ->
    # console.log "[insertFileView] hide, opened =#{@opened}"
    if @opened.picker
      @hide_picker()
    else if @opened.popover
      @hide_popover()

  hide_picker: ->
    # console.log "[insertFileView] hide picker"
    window.application_view.drawer_view.close()
    @opened.picker = false

  hide_from_picker: (stack_size) ->
    if stack_size == 0
      @opened.picker = false

  hide_popover: ->
    @$link.popover('hide')
    @opened.popover = false

  _input_el: (property, type) ->
    type ||= 'input'
    name = "rte_input_image_form[#{property}]"
    @$popover.find("#{type}[name=\"#{name}\"]")

  remove: ->
    # console.log "[insertFileView] remove"
    @detach_popover_events()
    @$link.popover('destroy')
    @$('.popover').remove()
    PubSub.unsubscribe(@pubsub_token)
    super
