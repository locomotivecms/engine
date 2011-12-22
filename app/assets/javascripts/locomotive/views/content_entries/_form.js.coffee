#= require ../shared/form_view

Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'submit': 'save'

  initialize: ->
    @model = new Locomotive.Models.ContentEntry(@options.content_entry)

    Backbone.ModelBinding.bind @

  render: ->
    super()

    return @

