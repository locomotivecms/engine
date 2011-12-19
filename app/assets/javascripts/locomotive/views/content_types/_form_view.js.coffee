#= require ../shared/form_view

Locomotive.Views.ContentTypes ||= {}

class Locomotive.Views.ContentTypes.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'submit': 'save'

  initialize: ->
    @model = new Locomotive.Models.ContentType(@options.content_type)

    window.foo = @model

    Backbone.ModelBinding.bind @

  render: ->
    super()

    @render_custom_fields()

    return @

  render_custom_fields: ->
    @custom_fields_view = new Locomotive.Views.ContentTypes.CustomFieldsView model: @model #, errors: @options.errors

    @$('#custom_fields_input').append(@custom_fields_view.render().el)

  remove: ->
    @custom_fields_view.remove()
    super

