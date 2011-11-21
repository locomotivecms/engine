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

    return @

  toggle_change: (event) ->
    @_toggle event, 'change',
      on_change: =>
        @$('a:first').hide() & @$('input[type=file]').show() & @$('a.delete').hide()
      on_cancel: =>
        @$('a:first').show() & @$('input[type=file]').hide() & @$('a.delete').show()

  toggle_delete: (event) ->
    @_toggle event, 'delete',
      on_change: =>
        @$('a:first').addClass('deleted') & @$('a.change').hide()
        @$('input[type=hidden].remove-flag').val('1')
      on_cancel: =>
        @$('a:first').removeClass('deleted') & @$('a.change').show()
        @$('input[type=hidden].remove-flag').val('0')

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


# toggle_change: (event) ->
#   event.stopPropagation() & event.preventDefault()
#
#   button  = $(event.target)
#   label   = button.attr('data-cancel-label')
#
#   unless @changing
#     @$('a:first').hide() & @$('input[type=file]').show() & @$('a.delete').hide()
#   else
#     @$('a:first').show() & @$('input[type=file]').hide() & @$('a.delete').show()
#
#   button.attr('data-alt-label', button.html())
#
#   button.html(label)
#
#   @changing = !@changing