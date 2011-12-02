Locomotive.Views.Sites ||= {}

class Locomotive.Views.Sites.DomainEntryView extends Backbone.View

  tagName: 'li'

  className: 'domain'

  events:
    'change input[type=text]' : 'change'
    'click a.remove':           'remove'

  render: ->
    $(@el).html(ich.domain_entry(@model.toJSON()))

    return @

  change: (event) ->
    value = $(event.target).val()
    @options.parent_view.change_entry(@model, value)

  remove: (event) ->
    event.stopPropagation() & event.preventDefault()
    @$('input[type=text]').editableField('destroy')
    @options.parent_view.remove_entry(@model)
    super()