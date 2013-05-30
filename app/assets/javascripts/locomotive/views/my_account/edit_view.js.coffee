#= require ../shared/form_view

Locomotive.Views.MyAccount ||= {}

class Locomotive.Views.MyAccount.EditView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'click .api_key.input button': 'regenerate_api_key'
    'submit': 'save'

  initialize: ->
    @model = new Locomotive.Models.CurrentAccount(@options.account)

    Backbone.ModelBinding.bind @

  render: ->
    super()

  save: (event) ->
    if @model.get('locale') == window.locale
      @save_in_ajax(event)

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


