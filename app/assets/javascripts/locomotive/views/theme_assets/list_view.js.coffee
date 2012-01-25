#= require ../shared/list_view

Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.ListView extends Locomotive.Views.Shared.ListView

  className: 'box'

  initialize: ->
    @collection = new Locomotive.Models.ThemeAssetsCollection(@options.collection)
    super

  template: ->
    ich.images_list

  item_view_class: ->
    Locomotive.Views.ThemeAssets.ListItemView
