Locomotive.Views.Snippets ||= {}

class Locomotive.Views.Snippets.ItemView extends Backbone.View

  tagName: 'li'

  events:
    'click a.remove': 'remove_snippet'

  render: ->
    $(@el).html(ich.snippet_item(@model.toJSON()))

    return @

  remove_snippet: (event) ->
    event.stopPropagation() & event.preventDefault()

    if confirm $(event.target).attr('data-confirm')
      @model.destroy()
