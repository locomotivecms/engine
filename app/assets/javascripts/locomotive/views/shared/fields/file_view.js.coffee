Locomotive.Views.Shared ||= {}
Locomotive.Views.Shared.Fields ||= {}

class Locomotive.Views.Shared.Fields.FileView extends Backbone.View

  tagName: 'span'

  className: 'file'

  states:
    change: false
    delete: false

  events:
    'click a.change': 'toggle_change'
    'click a.delete': 'toggle_delete'

  template: ->
    ich["#{@options.name}_file_input"]

  render: ->
    url   = @model.get("#{@options.name}_url") || ''
    data  =
      filename: url.split('/').pop()
      url:      url

    $(@el).html(@template()(data))

    # only in HTML 5
    @$('input[type=file]').bind 'change', (event) =>
      input = $(event.target)[0]

      if input.files?
        name  = $(input).attr('name')
        hash  = {}
        hash[name.replace("#{@model.paramRoot}[", '').replace(/]$/, '')] = input.files[0]
        @model.set(hash)

    return @

  refresh: ->
    @$('input[type=file]').unbind 'change'
    @states = { 'change': false, 'delete': false }
    @render()

  reset: ->
    @model.set_attribute @options.name, null
    @model.set_attribute "#{@options.name}_url", null
    @refresh()

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
        @model.set_attribute("remove_#{@options.name}", true)
      on_cancel: =>
        @$('a:first').removeClass('deleted') & @$('a.change').show()
        @$('input[type=hidden].remove-flag').val('0')
        @model.set_attribute("remove_#{@options.name}", false)

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
