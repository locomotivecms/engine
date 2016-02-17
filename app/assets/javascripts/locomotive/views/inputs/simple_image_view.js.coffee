#= require ./image_view

Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.SimpleImageView extends Locomotive.Views.Inputs.ImageView

  events: _.extend {}, Locomotive.Views.Inputs.ImageView.prototype.events,
    'change input[type=file]': 'change_file'

  render: ->
    super

    @$fields  =
      file:     @$('input[type=file]')
      remove:   @$('input[type=hidden].remove')

  undo: (event) ->
    # reset file input
    @$fields.file.wrap('<form>').parent('form').trigger('reset')
    @$fields.file.unwrap()

    super

  change_file: (event) ->
    file = if event.target.files then event.target.files[0] else null

    return if !file? || !file.type.match('image.*')

    @current_filename ||= @$('.file-name').html()

    @$spinner.show() & @update_filename(file.name)

    # ask for a cropped/resized version of the image
    @image_to_base_64 file, (base64) =>
      window.resize_image base64, @resize_format, (resized_image) =>
        @update_ui true, true, resized_image, file.name
        @$spinner.hide()

  update_ui: (with_file, undo_enabled, url, filename) ->
    value = if with_file then '0' else '1'
    @$fields.remove.val(value)

    super

  image_to_base_64: (file, callback) ->
    reader = new FileReader()
    reader.onload = (e) -> callback(e.target.result)
    reader.readAsDataURL(file)
