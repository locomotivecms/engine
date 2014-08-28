Locomotive.Views.Inputs.Rte ||= {}

class Locomotive.Views.Inputs.Rte.LinkView extends Backbone.View

  CLASS_NAME_OPENED: 'wysihtml5-command-dialog-opened'

  opened: false

  initialize: ->
    _.bindAll(@, 'apply', 'show', 'hide')

    @$link      = $(@el)
    @editor     = @options.editor
    @$content   = @$link.next('.link-dialog-content')

  render: ->
    console.log 'render LINKVIEW'
    @create_popover()

    @attach_events()
    @attach_popover()

    window.view = @

  create_popover: ->
    @$content.show()
    @$link.popover
      container:  '.main'
      placement:  'bottom'
      content:    @$content
      html:       true
      template:   '<div class="popover" role="tooltip"><div class="arrow"></div><form><div class="popover-content"></div></form></div>'
    @$link.data('bs.popover').setContent()

  attach_events: ->
    @$content.parents('form').on 'click', '.apply', @apply
    @$content.on 'click', '.apply', @apply
    @$content.on 'click', '.cancel', @hide

  attach_popover: ->
    command = @editor.toolbar.commandMapping['createLink:null']
    command.dialog = @

  apply: (event) ->
    console.log 'apply!!!'
    url = @$content.find('input[name=url]').val()

    unless _.isEmpty(url)
      @editor.composer.commands.exec 'createLink',
        href:   url
        target: @$content.find('select[name=target]').val()
        title:  @$content.find('input[name=title]').val()
        rel:    "nofollow"

      @hide()

  show: (state) ->
    console.log('Opening new create link dialog')
    window.bar = state
    window.foo = @$link
    window.link = @

    # @$link.addClass(@CLASS_NAME_OPENED)

    if state?
      $link = $(state)
      @$content.find('input[name=url]').val($link.attr('href'))
      @$content.find('select[name=target]').val($link.attr('target'))
      @$content.find('input[name=title]').val($link.attr('title'))

      @$link.popover('show') if !@opened
    else
      @$content.parents('form')[0].reset()

    @opened = true

  hide: ->
    console.log('Closing new create link dialog')
    # @$link.removeClass(@CLASS_NAME_OPENED)
    @$link.popover('hide')
    @opened = false

  remove: ->
    @$link.popover('destroy')

  # get: ->
  #   $form   = @$content.parents('form')
  #   $inputs = $form.find('input, select')



