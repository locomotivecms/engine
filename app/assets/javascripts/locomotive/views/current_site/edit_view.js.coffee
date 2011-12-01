#= require ../shared/form_view
#= require ../sites/domains_view

Locomotive.Views.CurrentSite ||= {}

class Locomotive.Views.CurrentSite.EditView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'submit': 'save'

  initialize: ->
    @model = new Locomotive.Models.CurrentSite(@options.site)

    Backbone.ModelBinding.bind @

    window.foo = @model

  render: ->
    super()

    @render_domains()

    @render_memberships()

    @enable_liquid_editing()

  render_domains: ->
    @domains_view = new Locomotive.Views.Site.DomainsView model: @model, errors: @options.errors

    @$('#site_domains_input label').after(@domains_view.render().el)

  render_memberships: ->
    @memberships_view = new Locomotive.Views.Site.MembershipsView model: @model

    @$('#site_memberships_input').append(@memberships_view.render().el)

  enable_liquid_editing: ->
    input = @$('#site_robots_txt')
    @editor = CodeMirror.fromTextArea input.get()[0],
      mode:             'liquid'
      autoMatchParens:  false
      lineNumbers:      false
      passDelay:        50
      tabMode:          'shift'
      theme:            'default'
      onChange: (editor) => @model.set(robots_txt: editor.getValue())

  save: (event) ->
    if @model.includes_domain(window.location.host)
      @save_in_ajax(event)

  show_error: (attribute, message, html) ->
    if attribute == 'domains'
      @domains_view.show_error(message)
    else
      super

  remove: ->
    @domains_view.remove()
    @memberships_view.remove()
    super

