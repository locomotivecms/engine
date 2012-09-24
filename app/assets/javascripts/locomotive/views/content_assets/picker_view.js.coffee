#= require ../shared/asset_picker_view

Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.PickerView extends Locomotive.Views.Shared.AssetPickerView

  number_items_per_row: 4

  _item_views: []

  template: ->
    ich.content_asset_picker

  fetch_assets: ->
    @_reset()
    @collection.fetch
      success: () =>
        @open()

  build_uploader: (el, link) ->
    link.bind 'click', (event) ->
      event.stopPropagation() & event.preventDefault()
      el.click()

    el.bind 'change', (event) =>
      _.each event.target.files, (file) =>
        asset = new Locomotive.Models.ContentAsset(source: file)
        asset.save {},
          headers:  { 'X-Flash': true }
          success:  (model, response) => @collection.add(model.prepare())
          error:    => @shake()

  add_asset: (asset, first) ->
    view = new Locomotive.Views.ContentAssets.PickerItemView model: asset, parent: @

    (@_item_views ||= []).push(view)
    @$('ul.list .clear').before(view.render().el)

    @_refresh()

    @_move_to_last_asset() unless first == true

  remove_asset: (asset) ->
    view = _.find @_item_views, (tmp) -> tmp.model == asset
    view.remove() if view?
    @_refresh()

  _on_refresh: ->
    self = @
    @$('ul.list li.asset').each (index) ->
      if (index + 1) % self.number_items_per_row == 0
        $(@).addClass('last')
      else
        $(@).removeClass('last')

  _reset: ->
    _.each @_item_views || [], (view) -> view.remove()
    super()