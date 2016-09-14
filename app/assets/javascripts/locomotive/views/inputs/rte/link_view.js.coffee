Locomotive.Views.Inputs.Rte ||= {}

class Locomotive.Views.Inputs.Rte.LinkView extends Backbone.View

  isOpen: false

  container:
    dataset:
      showdialogonselection: false

  initialize: ->
    _.bindAll(@, 'apply', 'show', 'hide')

    @$link      = @$('a[data-wysihtml5-command=createLink]')
    @editor     = @options.editor
    @$content   = @$link.next('.link-dialog-content')

    @$content.find('.input.select select:not(.disable-select2)').data('select2').$dropdown.addClass('rte-select2-dropdown')

  render: ->
    @attach_editor()
    @create_popover()
    @attach_events()

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
    @$content.on 'click', '.apply', @apply
    @$content.on 'click', '.cancel', @hide

  detach_events: ->
    @$content.off 'click', '.apply', @apply
    @$content.off 'click', '.cancel', @hide

  attach_editor: ->
    command = @editor.toolbar.commandMapping['createLink:null']
    command.dialog = @

  apply: (event) ->
    url = @_input_el('url').val()

    unless _.isEmpty(url)
      @editor.composer.commands.exec 'createLink',
        href:   url
        target: @_input_el('target', 'select').val()
        title:  @_input_el('title').val()

      # prevents the popover to be opened right after inserting the link.
      @editor.toolbar._preventInstantFocus()

      @hide()

  show: (state) ->
    # Fix a bug when opening an existing link for the first time
    return if @isOpen && state != false

    if state == false
      @$content.parents('form')[0].reset()
    else
      $link = $(state)
      @_input_el('url').val($link.attr('href'))
      @_input_el('target', 'select').val($link.attr('target'))
      @_input_el('title').val($link.attr('title'))

    @$link.popover('toggle')
    @_input_el('url').focus() # first field

    @isOpen = true

  update: (state) ->
    # do nothing

  hide: ->
    @_input_el('target', 'select').select2('close')
    @$link.popover('hide')
    @isOpen = false

  _input_el: (property, type) ->
    type ||= 'input'
    name = "rte_input_link_form[#{property}]"
    @$content.find("#{type}[name=\"#{name}\"]")

  remove: ->
    @detach_events()
    @$link.popover('destroy')
    @$('.popover').remove()

