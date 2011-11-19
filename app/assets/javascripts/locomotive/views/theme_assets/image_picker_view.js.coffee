#= require ../shared/asset_picker_view

Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.ImagePickerView extends Locomotive.Views.Shared.AssetPickerView

  events:
    'click ul.list a':  'select_asset'

  template: ->
    ich.theme_image_picker

  fetch_assets: ->
    @collection.fetch data: { content_type: 'image' }

  build_uploader: (el, link) ->
    window.LocomotiveUploadify.build el,
      url:        link.attr('href')
      data_name:  el.attr('name')
      height:     link.outerHeight()
      width:      link.outerWidth()
      success:    (model) => @collection.add(model)
      error:      (msg)   => @shake()

  select_asset: (event) ->
    event.stopPropagation() & event.preventDefault()
    if @options.on_select
      @options.on_select($(event.target).html())

  add_asset: (asset) ->
    @$('ul.list').append(ich.theme_asset(asset.toJSON()))
    @_refresh()