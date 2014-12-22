Locomotive.Views.Inputs.Rte ||= {}

class Locomotive.Views.Inputs.Rte.LinkView extends Backbone.View

  opened: false

  initialize: ->
    _.bindAll(@, 'apply', 'show', 'hide')

    @$link      = $(@el)
    @editor     = @options.editor
    @$content   = @$link.next('.link-dialog-content')

  render: ->
    @create_popover()

    @attach_events()
    @attach_popover()

  create_popover: ->
    @$content.show()
    @$link.popover
      container:  '.drawer'
      placement:  'left'
      content:    @$content
      html:       true
      template:   '<div class="popover" role="tooltip"><div class="arrow"></div><form class="simple_form"><div class="popover-content"></div></form></div>'
    @$link.data('bs.popover').setContent()

  attach_events: ->
    @$content.parents('form').on 'click', '.apply', @apply
    @$content.on 'click', '.apply', @apply
    @$content.on 'click', '.cancel', @hide

  attach_popover: ->
    command = @editor.toolbar.commandMapping['createLink:null']
    command.dialog = @

  apply: (event) ->
    url = @_input_el('url').val()

    unless _.isEmpty(url)
      @editor.composer.commands.exec 'createLink',
        href:   url
        target: @_input_el('target', 'select').val()
        title:  @_input_el('title').val()
        rel:    "nofollow"

      @hide()

  show: (state) ->
    if state?
      $link = $(state)
      @_input_el('url').val($link.attr('href'))
      @_input_el('target', 'select').val($link.attr('target'))
      @_input_el('title').val($link.attr('title'))

      @$link.popover('show') if !@opened
    else
      @$content.parents('form')[0].reset()

    @opened = true

  hide: ->
    @$link.popover('hide')
    @opened = false

  _input_el: (property, type) ->
    type ||= 'input'
    name = "rte_input_link_form[#{property}]"
    @$content.find("#{type}[name=\"#{name}\"]")

  remove: ->
    @$link.popover('destroy')
    @$('.popover').remove()
    # TODO: unattach events?

