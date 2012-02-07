#= require ../shared/form_view

Locomotive.Views.MyAccount ||= {}

class Locomotive.Views.MyAccount.EditView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'submit': 'save'

  initialize: ->
    @model = new Locomotive.Models.CurrentAccount(@options.account)

    Backbone.ModelBinding.bind @

  render: ->
    super()

  save: (event) ->
    if @model.get('locale') == window.locale
      @save_in_ajax(event)


