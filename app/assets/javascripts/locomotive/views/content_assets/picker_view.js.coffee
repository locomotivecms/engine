#= require ../shared/asset_picker_view

Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.PickerView extends Locomotive.Views.Shared.AssetPickerView

  number_items_per_row: 4

  page:                 1

  per_page:             12

  total_pages:          null

  uploading:            false

  _item_views:          []

  events:
    'click .btn':                 'toggle_filter_by_type'
    'change input[name=query]':   'fetch_assets'

  render: ->
    super

    @enable_dropzone()

    @enable_infinite_scroll()

    @

  template: ->
    ich.content_asset_picker

  fetch_assets: (event) ->
    @_reset()
    xhr = @collection.fetch
      data:     @_fetch_options()
      reset:    true
      success:  => @open()

    xhr.done => @_get_pagination_info(xhr)

  toggle_filter_by_type: (event) ->
    $(event.target).toggleClass('on')
    @fetch_assets()

  build_uploader: (el, link) ->
    link.bind 'click', (event) ->
      event.stopPropagation() & event.preventDefault()
      el.click()

    el.bind 'change', (event) => @_persist_files(event)

  add_asset: (asset, first) ->
    view = new Locomotive.Views.ContentAssets.PickerItemView model: asset, parent: @

    (@_item_views ||= []).push(view)

    if @uploading
      @$('ul.list').prepend(view.render().el)
      @_refresh()
    else
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

  enable_infinite_scroll: ->
    $list = @$('ul.list')

    $list.on 'scroll', (event) =>
      clearTimeout(@throttle_timer) if @throttle_timer?

      @throttle_timer = setTimeout =>
        height = $list[0].scrollHeight - $list.innerHeight()
        scroll = $list.scrollTop()

        isScrolledToEnd = (scroll >= height)

        if isScrolledToEnd && @page < @total_pages
          @page += 1
          xhr = @collection.fetch
            data: { page: @page, per_page: @per_page }
            success: () =>
              @_refresh()
              $list.scrollTop(scroll)
          xhr.done => @_get_pagination_info(xhr)
      , 100

  remove_asset: (asset) ->
    view = _.find @_item_views, (tmp) -> tmp.model == asset
    view.remove() if view?
    @_refresh()

  dialog_class: ->
    'content-asset-picker-dialog'

  _fetch_options: ->
    _.tap { per_page: @per_page }, (options) =>
      options.types = []

      @$('.asset-types .btn.on').each ->
        options.types.push $(this).data('type')

      options.query = @$('input[name=query]').val()

  _persist_files: (event) ->
    files = event.target.files || event.originalEvent.dataTransfer.files

    @_move_to_top()
    @uploading = true

    _.each files, (file) =>
      # create a new asset
      asset = new Locomotive.Models.ContentAsset(uploading: true, source: file)
      @collection.add(asset.prepare(), at: 0)

      # create the view at first
      view = @_find_view_by_asset(asset)

      # async save
      asset.save {},
        headers:  { 'X-Flash': true }
        success:  (model, response) =>
          asset.set(uploading: false)
          asset.prepare()
          view.refresh()
        error:    => @shake()
        progress: (loaded, total) => view.uploaded_at(loaded, total)

    @uploading = false

    # what's the total pages now ?
    @_recalculate_pagination(_.size(files))

  _recalculate_pagination: (number_assets_added) ->
    previous_total_pages = @total_pages

    # not on the last page ?
    if @page < @total_pages
      number_assets_to_delete = number_assets_added % @per_page

      while number_assets_to_delete -= 1
        @collection.pop()

    # not a problem if the total pages is not super accurate because it will
    # be recalculated at the next scroll
    @total_entries  += number_assets_added
    @total_pages    = Math.ceil(@total_entries / @per_page)

    # move the current page to the new last one if we already were at the last page
    @page = @total_pages if @page == previous_total_pages || previous_total_pages == 0

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

  _get_pagination_info: (xhr) ->
    @total_pages    = parseInt(xhr.getResponseHeader('X-Total-Pages'))
    @per_page       = parseInt(xhr.getResponseHeader('X-Per-Page'))
    @total_entries  = parseInt(xhr.getResponseHeader('X-Total-Entries'))

  _reset: ->
    @page = 1
    @total_pages = null
    _.each @_item_views || [], (view) -> view.remove()
    super()