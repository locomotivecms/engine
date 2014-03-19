#= require ../shared/asset_picker_view

Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.PickerView extends Locomotive.Views.Shared.AssetPickerView

  number_items_per_row: 4

  _item_views: []

  render: ->
    super

    @enable_dropzone()

    @

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

    el.bind 'change', (event) => @_persist_files(event)

  add_asset: (asset, first) ->
    view = new Locomotive.Views.ContentAssets.PickerItemView model: asset, parent: @

    (@_item_views ||= []).push(view)
    @$('ul.list .clear').before(view.render().el)

    @_refresh()

    @_move_to_last_asset() unless first == true

  enable_dropzone: ->
    # make sure it works for the browser
    return unless window.File && window.FileList && window.FileReader

    dropzone = @$('ul.list').parent()

    dropzone.on 'dragover',   (event) => @_stop_event(event); dropzone.addClass('hovered')
    dropzone.on 'dragleave',  (event) => @_stop_event(event); dropzone.removeClass('hovered')
    dropzone.on 'dragenter',  (event) => @_stop_event(event)
    dropzone.on 'drop',       (event) =>
      @_stop_event(event)
      dropzone.removeClass('hovered')
      @_persist_files(event)

  remove_asset: (asset) ->
    view = _.find @_item_views, (tmp) -> tmp.model == asset
    view.remove() if view?
    @_refresh()

  _persist_files: (event) ->
    files = event.target.files || event.originalEvent.dataTransfer.files

    _.each files, (file) =>
      # create a new asset
      asset = new Locomotive.Models.ContentAsset(uploading: true, source: file)
      @collection.add(asset.prepare())

      # create the view at first
      view = @_find_view_by_asset(asset)

      # async save
      asset.save {},
        headers:  { 'X-Flash': true }
        success:  (model, response) =>
          asset.set(uploading: false)
          asset.prepare()
          view.refresh()
          @_refresh()
        error:    => @shake()
        progress: (loaded, total) => view.uploaded_at(loaded, total)

  _on_refresh: ->
    self = @
    @$('ul.list li.asset').each (index) ->
      if (index + 1) % self.number_items_per_row == 0
        $(@).addClass('last')
      else
        $(@).removeClass('last')

  _find_view_by_asset: (asset) ->
    _.find @_item_views || [], (view) -> view.model.cid == asset.cid

  _stop_event: (event) ->
    event.stopPropagation() & event.preventDefault()

  _reset: ->
    _.each @_item_views || [], (view) -> view.remove()
    super()