Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.FileView extends Backbone.View

  tagName: 'li'

  className: 'file input'

  states:
    change: false
    delete: false

  events:
    'click a.change': 'toggle_change'
    'click a.delete': 'toggle_delete'

  render: ->
    $(@el).html(ich.editable_file_input(@model.toJSON()))

    # only in HTML 5
    @$('input[type=file]').bind 'change', (event) =>
      input = $(event.target)[0]
      if input.files?
        @model.set(source: input.files[0])

    return @

  after_render: ->
    # do nothing

  refresh: ->
    @$('input[type=file]').unbind 'change'
    @states = { 'change': false, 'delete': false }
    @render()

  toggle_change: (event) ->
    @_toggle event, 'change',
      on_change: =>
        @$('a:first').hide() & @$('input[type=file]').show() & @$('a.delete').hide()
      on_cancel: =>
        @model.set(source: null)
        @$('a:first').show() & @$('input[type=file]').val('').hide() & @$('a.delete').show()

  toggle_delete: (event) ->
    @_toggle event, 'delete',
      on_change: =>
        @$('a:first').addClass('deleted') & @$('a.change').hide()
        @$('input[type=hidden].remove-flag').val('1')
        @model.set('remove_source': true)
      on_cancel: =>
        @$('a:first').removeClass('deleted') & @$('a.change').show()
        @$('input[type=hidden].remove-flag').val('0')
        @model.set('remove_source': false)

  _toggle: (event, state, options) ->
    event.stopPropagation() & event.preventDefault()

    button  = $(event.target)
    label   = button.attr('data-alt-label')

    unless @states[state]
      options.on_change()
    else
      options.on_cancel()

    button.attr('data-alt-label', button.html())

    button.html(label)

    @states[state] = !@states[state]

  remove: ->
    @$('input[type=file]').unbind 'change'
    super
