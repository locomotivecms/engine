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

# Locomotive.Views.Inputs ||= {}

# class Locomotive.Views.Inputs.SimpleImageView extends Backbone.View

#   events:
#     'click *[data-action=delete]':  'mark_file_as_deleted'
#     'click *[data-action=undo]':    'undo'
#     'change input[type=file]':      'change_file'

#   render: ->
#     @$spinner = @$('.file-wrapper .spinner')
#     @$fields  =
#       file:     @$('input[type=file]')
#       remove:   @$('input[type=hidden].remove')

#     @urls =
#       default:  @$('.file-wrapper').data('default-url')
#       current:  @$('.file-wrapper').data('url')

#     @initial_state  = if @urls.current == '' then 'no_file' else 'existing_file'
#     @urls.current   = @urls.default if _.isEmpty(@urls.current)

#     @resize_format  = @$('.file-wrapper').data('resize')
#     @no_file_label  = @$('.file-wrapper').data('no-file-label')

#   mark_file_as_deleted: (event) ->
#     if @initial_state == 'existing_file'
#       @current_filename = @$('.file-name').html()
#       @update_ui false, true, @urls.default, @no_file_label

#   undo: (event) ->
#     # reset file input
#     @$fields.file.wrap('<form>').parent('form').trigger('reset')
#     @$fields.file.unwrap()

#     @update_ui true, false, @urls.current, @current_filename || @no_file_label

#   change_file: (event) ->
#     file = if event.target.files then event.target.files[0] else null

#     return if !file? || !file.type.match('image.*')

#     @current_filename ||= @$('.file-name').html()

#     @$spinner.show() & @update_filename(file.name)

#     # ask for a cropped/resized version of the image
#     @image_to_base_64 file, (base64) =>
#       window.resize_image base64, @resize_format, (resized_image) =>
#         @update_ui true, true, resized_image, file.name
#         @$spinner.hide()

#   image_to_base_64: (file, callback) ->
#     reader = new FileReader()
#     reader.onload = (e) -> callback(e.target.result)
#     reader.readAsDataURL(file)

#   update_ui: (with_file, undo_enabled, url, filename) ->
#     value = if with_file then '0' else '1'
#     @$fields.remove.val(value)

#     if undo_enabled
#       @$('*[data-action=delete]').hide()
#       @$('*[data-action=undo]').show()
#     else
#       @$('*[data-action=undo]').hide()
#       @$('*[data-action=delete]').show() unless @initial_state == 'no_file'

#     @$('.file-image img').attr('src', url)

#     @update_filename(filename)

#   update_filename: (name) ->
#     @$('.file-name').html(name) unless _.isEmpty(name)

