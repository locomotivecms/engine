Locomotive.notify = (message, type) ->
  icon = if type == 'danger'
    'exclamation-triangle'
  else if type == 'success'
    'check'
  else
    'exclamation-circle'

  $.notify { message: message, icon: "fa fa-#{icon}" },
    type: type
    placement:
      from:   'bottom'
      align:  'right'
