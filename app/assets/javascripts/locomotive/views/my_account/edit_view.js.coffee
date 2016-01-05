#= require ../shared/form_view

Locomotive.Views.MyAccount ||= {}

class Locomotive.Views.MyAccount.EditView extends Locomotive.Views.Shared.FormView

  el: '.public-box'

  events:
    'click .api_key.input button':  'regenerate_api_key'
    'submit form':                  'save'

  regenerate_api_key: (event) ->
    event.stopPropagation() & event.preventDefault()

    button = $(event.target)

    if confirm(button.data('confirm'))
      $.rails.ajax
        url:        button.data('url')
        type:       'put'
        dataType:   'json'
        success:    (data) =>
          button.prev('code').html(data.api_key)
