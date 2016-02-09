Locomotive.Views.ContentAssets ||= {}

class Locomotive.Views.ContentAssets.DropzoneView extends Backbone.View

  events:
    'click a.upload':           'open_file_browser'
    'dragover':                 'hover'
    'dragleave':                'unhover'
    'dragenter':                '_stop_event'
    'drop':                     'drop_files'
    'change input[type=file]':  'drop_files'

  render: ->
    # console.log '[DropzoneView] rendering'
    super

  hover: (event) -> @_stop_event(event); $(@el).addClass('hovered')
  unhover: (event) -> @_stop_event(event); $(@el).removeClass('hovered')

  show_progress: (value) ->
    @$('.progress').removeClass('hide').find('> .progress-bar').width("#{value}%")

  reset_progress: ->
    setTimeout =>
      @$('.progress').addClass('hide').find('> .progress-bar').width('0%')
    , 400

  open_file_browser: (event) ->
    # console.log '[DropzoneView] open_file_browser'
    @_stop_event(event)

    @$('form input[type=file]').trigger('click')

  drop_files: (event) ->
    # console.log '[DropzoneView] drop_files'
    @_stop_event(event) & @unhover(event)

    form_data = new FormData()

    _.each event.target.files || event.originalEvent.dataTransfer.files, (file, i) ->
      form_data.append("content_assets[][source]", file)

    @upload_files(form_data)

  upload_files: (data) ->
    $.ajax @_ajax_options(data)
    .always =>
      @reset_progress()
    .fail =>
      @$('.instructions').effect('shake')
    .done =>
      console.log 'uploaded'
      @_refresh()

  _refresh: ->
    $link = @$('a.refresh')
    if $link.data('remote')
      $link.trigger 'click'
    else
      $link[0].click()

  _ajax_options: (data) ->
    url:          $(@el).data('url')
    type:         'POST'
    xhr:          => @_build_xhr()
    data:         data
    dataType:     'json'
    cache:        false
    contentType:  false
    processData:  false

  _build_xhr: ->
    _.tap $.ajaxSettings.xhr(), (xhr) =>
      if xhr.upload
        xhr.upload.addEventListener 'progress', (progress) =>
          @show_progress ~~((progress.loaded / progress.total) * 100)

  _stop_event: (event) ->
    event.stopPropagation() & event.preventDefault()
    true
