Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.FileView extends Backbone.View

  events:
    'change input[type=file]':  'change_file'
    'click a.choose':           'begin_choose_file'
    'click a.change':           'begin_change_file'
    'click a.content-assets':   'open_content_assets_drawer'
    'click a.cancel':           'cancel_new_file'
    'click a.delete':           'mark_file_as_deleted'

  initialize: ->
    _.bindAll(@, 'use_content_asset')

    @$file          = @$('input[type=file]')
    @$remove_file   = @$('input[type=hidden].remove')
    @$remote_url    = @$('input[type=hidden].remote-url')
    @$current_file  = @$('.current-file')
    @$no_file       = @$('.no-file')
    @$new_file      = @$('.new-file')

    @$choose_btn    = @$('.buttons > .choose')
    @$change_btn    = @$('.buttons > .change')
    @$cancel_btn    = @$('.buttons .cancel')
    @$delete_btn    = @$('.buttons .delete')

    @persisted_file = @$('.row').data('persisted-file')
    @path           = $(@el).data('path')

    @pubsub_token   = PubSub.subscribe 'file_picker.select', @use_content_asset

  begin_change_file: -> @$file.click()
  begin_choose_file: -> @$file.click()

  open_content_assets_drawer: (event) ->
    event.stopPropagation() & event.preventDefault()

    $(event.target).closest('.btn-group').removeClass('open')

    window.application_view.drawer_view.open(
      $(event.target).attr('href'),
      Locomotive.Views.ContentAssets.PickerView,
      { parent_view: @ })

  use_content_asset: (msg, data) ->
    return unless data.parent_view.cid == @.cid

    window.application_view.drawer_view.close()

    url = window.absolute_url(data.url)

    window.remote_file_to_base64 url, (base64) =>
      if base64
        @update_ui_on_changing_file(data.title)

        # add the filename to the base64 string
        base64 = base64.replace(';base64,', ";#{data.filename};base64,")

        @$remote_url.val(base64)

        if data.image
          @$new_file.html("<img src='#{url}' /> #{@$new_file.html()}")

          PubSub.publish 'inputs.image_changed', { view: @, url: url }
      else
        Locomotive.notify 'Unable to load the asset', 'error'

  change_file: (event) ->
    file = if event.target.files then event.target.files[0] else null
    text = if file? then file.name else 'New file'

    @update_ui_on_changing_file(text)

    if file.type.match('image.*')
      @image_to_base_64 file, (base64) =>
        @$new_file.html("<img src='#{base64}' /> #{@$new_file.html()}")

        PubSub.publish 'inputs.image_changed', { view: @, url: base64, file: file }

  update_ui_on_changing_file: (text) ->
    @$new_file.html(text)

    # show new file, hide the current one
    @showEl(@$new_file) && @hideEl(@$current_file) && @hideEl(@$no_file)

    # only show the cancel button
    @hideEl(@$change_btn) && @hideEl(@$delete_btn) && @hideEl(@$choose_btn) && @showEl(@$cancel_btn)

  cancel_new_file: (event) ->
    # hide the new file
    @hideEl(@$new_file)

    # reset remote url
    @$remote_url.val('')

    # reset the file input
    @$file.wrap('<form>').closest('form').get(0).reset()
    @$file.unwrap()

    $(@el).removeClass('mark-as-removed')

    # no more mark file as deleted
    @$remove_file.val('0')

    # hide the cancel button
    @hideEl(@$cancel_btn)

    if @persisted_file
      # show the current file
      @showEl(@$current_file)

      # display the change + delete buttons
      @showEl(@$change_btn) && @showEl(@$delete_btn)
    else
      # show no_file
      @showEl(@$no_file)

      # display the choose button
      @showEl(@$choose_btn)

    PubSub.publish 'inputs.image_changed', { view: @ }

  mark_file_as_deleted: (event) ->
    # set true (or 1) as value for the remove_<method> hidden field
    @$remove_file.val('1')

    # add the "mark-as-removed" class to the el
    $(@el).addClass('mark-as-removed')

    # hide the change / delete buttons, show the cancel button
    @hideEl(@$change_btn) && @hideEl(@$delete_btn) && @showEl(@$cancel_btn)

    PubSub.publish 'inputs.image_removed', { view: @ }

  image_to_base_64: (file, callback) ->
    reader = new FileReader()
    reader.onload = (e) -> callback(e.target.result)
    reader.readAsDataURL(file)

  showEl: (el) -> el.removeClass('hide')
  hideEl: (el) -> el.addClass('hide')

  need_refresh: -> true

  remove: ->
    super
    PubSub.unsubscribe(@pubsub_token)
