#= require ../shared/form_view

Locomotive.Views.Translations ||= {}

class Locomotive.Views.Translations.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'submit': 'save'

  initialize: ->
    @model = new Locomotive.Models.Translation(@options.translation)

    Backbone.ModelBinding.bind @

  render: ->
    super()

    return @