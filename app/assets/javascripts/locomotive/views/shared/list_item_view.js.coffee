Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.ListItemView extends Backbone.View

  tagName: 'li'

  events:
    'click a.remove': 'remove_item'

  template: ->
    # please overide template

  render: ->
    $(@el).html(@template()(@model.toJSON()))

    return @

  remove_item: (event) ->
    event.stopPropagation() & event.preventDefault()

    if confirm $(event.target).attr('data-confirm')
      @model.destroy()
