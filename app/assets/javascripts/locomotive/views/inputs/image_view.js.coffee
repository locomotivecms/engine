Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.ImageView extends Backbone.View

  events:
    'click *[data-action=delete]':  'mark_file_as_deleted'
    'click *[data-action=undo]':    'undo'
    'click a.file-browse':          'open_content_assets_drawer'

  initialize: ->
    _.bindAll(@, 'change_file')
    @pubsub_token = PubSub.subscribe 'file_picker.select', @change_file

  render: ->
    @$spinner = @$('.file-wrapper .spinner')

    @urls =
      default:  @$('.file-wrapper').data('default-url')
      current:  @$('.file-wrapper').data('url')

    @initial_state  = if @urls.current == '' then 'no_file' else 'existing_file'
    @urls.current   = @urls.default if _.isEmpty(@urls.current)

    @resize_format  = @$('.file-wrapper').data('resize')
    @no_file_label  = @$('.file-wrapper').data('no-file-label')

  open_content_assets_drawer: (event) ->
    event.stopPropagation() & event.preventDefault()

    window.application_view.drawer_view.open(
      $(event.target).attr('href'),
      Locomotive.Views.ContentAssets.PickerView,
      { parent_view: @ })

  mark_file_as_deleted: (event) ->
    if @initial_state == 'existing_file'
      @current_filename = @$('.file-name').html()
      @update_ui false, true, @urls.default, @no_file_label

  undo: (event) ->
    @update_ui true, false, @urls.current, @current_filename || @no_file_label

  change_file: (msg, data) ->
    return unless data.parent_view.cid == @.cid

    window.application_view.drawer_view.close()

    url = window.absolute_url(data.url)

    # update the textfield storing the URL of the image
    @set_file_url(url)

    @current_filename ||= @$('.file-name').html()

    @$spinner.show() & @update_filename(data.filename)

    # ask for a cropped/resized version of the image
    window.resize_image url, @resize_format, (resized_image) =>
      @update_ui true, true, resized_image, data.filename
      @$spinner.hide()

  update_ui: (with_file, undo_enabled, url, filename) ->
    @set_file_url('') unless with_file

    if undo_enabled
      @$('*[data-action=delete]').hide()
      @$('*[data-action=undo]').show()
    else
      @$('*[data-action=undo]').hide()
      @$('*[data-action=delete]').show() unless @initial_state == 'no_file'

    @$('.file-image img').attr('src', url)

    @update_filename(filename)

  update_filename: (name) ->
    @$('.file-name').html(name) unless _.isEmpty(name)

  set_file_url: (url) ->
    @$('.file input[type=text]').val(url)

  remove: ->
    super
    PubSub.unsubscribe(@pubsub_token) if @pubsub_token?
