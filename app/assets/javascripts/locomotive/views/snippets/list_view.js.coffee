#= require ../shared/list_view

Locomotive.Views.Snippets ||= {}

class Locomotive.Views.Snippets.ListView extends Locomotive.Views.Shared.ListView

  className: 'box'

  initialize: ->
    @collection = new Locomotive.Models.SnippetsCollection(@options.collection)
    super

  template: ->
    ich.snippets_list

  item_view_class: ->
    Locomotive.Views.Snippets.ListItemView