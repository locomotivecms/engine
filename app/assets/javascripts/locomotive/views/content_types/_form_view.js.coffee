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

    @slugify_name() # slugify the slug field from name

    return @

  render_custom_fields: ->
    @custom_fields_view = new Locomotive.Views.ContentTypes.CustomFieldsView model: @model

    @$('#custom_fields_input').append(@custom_fields_view.render().el)

  slugify_name: ->
    @$('#content_type_name').slugify(target: @$('#content_type_slug'), sep: '_')

  show_error: (attribute, message, html) ->
    if attribute == 'contents_custom_fields'
      for _message, index in message
        @custom_fields_view._entry_views[index].show_error(_message[0])
    else
      super

  remove: ->
    @custom_fields_view.remove()
    super

