window.ImageUploadify =

  build: (el, options) ->
    multipart_params = @_get_default_multipart_params()

    el.uploadify
      script:           options.url
      multi:            true
      queueID:          null
      buttonText:       'edit'
      buttonImg:        null
      width:            options.width || 30
      height:           options.height || 30
      hideButton:       true
      wmode:            'transparent'
      auto:             true
      fileExt:          '*.jpg;*.png;*.jpeg;*.gif'
      fileDesc:         'Only .jpg, .png, .jpeg, .gif'
      removeCompleted:  true
      fileDataName:     options.data_name
      scriptData:       multipart_params
      onComplete:       (a, b, c, response, data) ->
        model = JSON.parse(response)
        options.success(model)
      onError:          (a, b, c, errorObj) ->
        options.error(errorObj) if options.error

  _get_default_multipart_params: ->
    _.tap { _method: 'post', '_http_accept': 'application/json' }, (params) ->
      params[$('meta[name=csrf-param]').attr('content')] = encodeURI(encodeURIComponent($('meta[name=csrf-token]').attr('content')));
      params[$('meta[name=key-param]').attr('content')] = $('meta[name=key-token]').attr('content');