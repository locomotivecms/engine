#= require ../shared/form_view
#= require ../sites/domains_view

Locomotive.Views.CurrentSite ||= {}

class Locomotive.Views.CurrentSite.EditView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'click .memberships a.remove': 'remove_membership'

  initialize: ->
    @model = new Locomotive.Models.CurrentSite(@options.site)

    Backbone.ModelBinding.bind @

    window.foo = @model

  render: ->
    super()

    @render_domain_entries()

    @enable_liquid_editing()

    @enable_ui_effects()

  render_domain_entries: ->
    @domains_view = new Locomotive.Views.Site.DomainsView model: @model, errors: @options.errors

    @$('#site_domains_input label').after(@domains_view.render().el)

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

  enable_ui_effects: ->
    @$('#site_domains_input .domain input[type=text]').editableField()
    @$('.memberships .entry .role select').editableField()

  remove_membership: (event) ->
    event.stopPropagation() & event.preventDefault()
    entry = $(event.target).parents('.entry').hide()
    entry.find('input[type=hidden]').val(1)

