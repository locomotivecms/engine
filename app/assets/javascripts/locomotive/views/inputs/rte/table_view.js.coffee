Locomotive.Views.Inputs.Rte ||= {}

class Locomotive.Views.Inputs.Rte.TableView extends Backbone.View

  container:
    dataset: []

  initialize: ->
    _.bindAll(@, 'apply', 'show', 'hide', 'show_link', 'hide_link')

    @$link    = @$('a[data-wysihtml5-command=createTable]')
    @editor   = @options.editor
    @$content = @$link.next('.table-dialog-content')

  render: ->
    return if @$link.size() == 0

    @create_popover()

    @attach_events()
    @attach_editor()

  create_popover: ->
    @$content.show()
    @$link.popover
      container:  @$link.parents('fieldset')
      placement:  'right'
      content:    @$content
      html:       true
      trigger:    'manual'
      template:   '<div class="popover" role="tooltip"><div class="arrow"></div><form class="simple_form"><div class="popover-content"></div></form></div>'
    @$link.data('bs.popover').setContent()

  attach_events: ->
    @$content.on 'click', '.apply',       @apply
    @$content.on 'click', '.cancel',      @hide
    @editor.on 'tableselect:composer',    @hide_link
    @editor.on 'tableunselect:composer',  @show_link

  detach_events: ->
    @$content.off 'click', '.apply',                @apply
    @$content.off 'click', '.cancel',               @hide
    @editor.stopObserving 'tableselect:composer',   @hide_link
    @editor.stopObserving 'tableunselect:composer', @show_link

  attach_editor: ->
    command = @editor.toolbar.commandMapping['createTable:null']
    command.dialog = @

  apply: (event) ->
    @editor.composer.commands.exec 'createTable',
      cols:       @_input_el('cols').val()
      rows:       @_input_el('rows').val()
      class_name: @_input_el('class_name').val()
      head:       @_input_el('head').last().bootstrapSwitch('state')

    @hide()

  show: (state) ->
    # console.log "[TableView] show (#{state})"
    @$link.popover('toggle')

    @$content.parents('form')[0].reset()

  update: (state) ->
    # do nothing

  hide: ->
    # console.log "[TableView] hide"
    @$link.popover('hide')

  show_link: ->
    @$link.show()

  hide_link: ->
    @$link.hide()

  _input_el: (property, type) ->
    type ||= 'input'
    name = "rte_input_table_form[#{property}]"
    @$content.find("#{type}[name=\"#{name}\"]")

  remove: ->
    @detach_events()
    @$link.popover('destroy')
    @$('.popover').remove()

