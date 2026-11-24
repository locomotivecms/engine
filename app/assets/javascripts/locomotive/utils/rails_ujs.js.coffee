# Feature: Confirm on action

$.rails.safe_confirm = (question) ->
  prompt(question.question) == question.answer

$.rails.allowAction = (element) ->
  message   = element.data('confirm')
  question  = element.data('safe-confirm')
  answer    = false
  callback  = null

  if !message && !question then return true

  if $.rails.fire(element, 'confirm')
    if message
      answer    = $.rails.confirm(message)
    else if question
      answer    = $.rails.safe_confirm(question)

    callback  = $.rails.fire(element, 'confirm:complete', [answer])

  answer && callback

# Feature: AJAX File upload
# Enhance the form: upload files in AJAX without monkey patching jQuery-UJS
# Information: https://github.com/rails/jquery-ujs/issues/374
$.rails.ajax = (options) ->
  if _.isArray(options.data) # FormData
    $.ajax(_.extend(options, contentType: false))
  else
    $.ajax(options)

$ ->
  # Tell the server to return flash messages in the header of the response
  $('body').on 'ajax:beforeSend', $.rails.formSubmitSelector, (event, xhr, settings) ->
    xhr.setRequestHeader('X-Flash', true)

  # Once we receive the response from the server, we display a notification
  # and also reset the submit button to its initial state (bootstrap)
  $('body').on 'ajax:complete', $.rails.formSubmitSelector, (event, xhr, status) ->
    $(this).find('button[type=submit], input[type=submit]').button('reset')

    if message = xhr.getResponseHeader('X-Message')
      type = if status == 'success' then 'success' else 'error'
      Locomotive.notify decodeURIComponent(JSON.parse(message)), type

  # We do not want forms to be aborted because of a file input
  $('body').on 'ajax:aborted:file', $.rails.formSubmitSelector, (element) ->
    $.rails.handleRemote($(this))
    false

  # Use the "new" FormData object (HTML5) to store the data, especially the uploaded files
  $('body').on 'ajax:beforeSend', $.rails.formSubmitSelector, (event, xhr, settings) ->
    settings.data = new FormData($(this)[0])
    $(this).find('input[type=file]').each -> settings.data.append($(this).attr('name'), this.files[0])
    true
