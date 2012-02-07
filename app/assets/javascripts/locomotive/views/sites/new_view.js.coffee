#= require ../shared/form_view
#= require ../sites/domains_view

Locomotive.Views.Sites ||= {}

class Locomotive.Views.Sites.NewView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'submit': 'save'

  initialize: ->
    @model = new Locomotive.Models.Site()

    Backbone.ModelBinding.bind @

  render: ->
    super()

    @render_domains()

  render_domains: ->
    @domains_view = new Locomotive.Views.Sites.DomainsView model: @model, errors: @options.errors

    @$('#site_domains_input label').after(@domains_view.render().el)

  save: (event) ->
    @save_in_ajax event,
      on_success: (response, xhr) ->
        window.location.href = xhr.getResponseHeader('location')

  show_error: (attribute, message, html) ->
    if attribute == 'domains'
      @domains_view.show_error(message)
    else
      super

  remove: ->
    @domains_view.remove()
    super


