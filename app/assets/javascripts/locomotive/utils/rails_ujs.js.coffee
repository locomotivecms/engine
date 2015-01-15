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
