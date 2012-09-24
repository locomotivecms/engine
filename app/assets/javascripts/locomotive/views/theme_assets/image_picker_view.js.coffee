#= require ../shared/asset_picker_view

Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.ImagePickerView extends Locomotive.Views.Shared.AssetPickerView

  events:
    'click ul.list a':  'select_asset'

  initialize: ->
    @collection ||= new Locomotive.Models.ThemeAssetsCollection()
    super

  template: ->
    ich.theme_image_picker

  fetch_assets: ->
    @_reset()
    @collection.fetch
      data:
        content_type: 'image'
      success: () =>
        @open()

  build_uploader: (el, link) ->
    link.bind 'click', (event) ->
      event.stopPropagation() & event.preventDefault()
      el.click()

    el.bind 'change', (event) =>
      _.each event.target.files, (file) =>
        asset = new Locomotive.Models.ThemeAsset(source: file)
        asset.save {},
          headers:  { 'X-Flash': true }
          success:  (model) => @collection.add(model)
          error:    => @shake()

  select_asset: (event) ->
    event.stopPropagation() & event.preventDefault()
    if @options.on_select
      @options.on_select($(event.target).html())

  add_asset: (asset) ->
    @$('ul.list').append(ich.theme_asset(asset.toJSON()))
    @_refresh()

  _reset: ->
    @$('ul.list').empty()