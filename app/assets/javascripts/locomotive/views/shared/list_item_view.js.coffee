Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.ListItemView extends Backbone.View

  tagName: 'li'

  events:
    'click a.remove': 'remove_snippet'

  template: ->
    # please overide template

  render: ->
    $(@el).html(@template()(@model.toJSON()))

    return @

  remove_snippet: (event) ->
    event.stopPropagation() & event.preventDefault()

    if confirm $(event.target).attr('data-confirm')
      @model.destroy()
