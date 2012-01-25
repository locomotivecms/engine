#= require ../shared/list_item_view

Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.ListItemView extends Locomotive.Views.Shared.ListItemView

  template: ->
    ich.editable_theme_asset_item