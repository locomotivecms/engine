#= require ../shared/form_view

Locomotive.Views.Contents ||= {}

class Locomotive.Views.Contents.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'submit': 'save'

  initialize: ->
    @model = new Locomotive.Models.Content(@options.content)

    Backbone.ModelBinding.bind @

  render: ->
    super()

    return @

