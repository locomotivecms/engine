Locomotive.Views.Site ||= {}

class Locomotive.Views.Site.DomainsView extends Backbone.View

  tagName: 'div'

  className: 'list'

  _entry_views = []

  events:
    'click .new-entry a.add': 'add_entry'
    'keypress .new-entry input[type=text]': 'add_on_entry_from_enter'

  render: ->
    $(@el).html(ich.domains_list(@model.toJSON()))

    @render_entries()

    return @

  add_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    input = @$('.new-entry input[name=domain]')

    if input.val() != ''
      domain = new Locomotive.Models.Domain name: input.val()

      @model.get('domains').push(domain)

      @_insert_entry(domain)

      @$('ul li.domain:last input[type=text]').editableField()
      @$('.empty').hide()

      input.val('') # reset for further entries

  add_on_entry_from_enter: (event) ->
    return if event.keyCode != 13
    @add_entry(event)

  change_entry: (domain, value) ->
    domain.set name: value

  remove_entry: (domain) ->
    list = _.reject @model.get('domains'), (_domain) => _domain == domain
    @model.set domains: list
    @$('.empty').show() if @model.get('domains').length == 0

  render_entries: ->
    if @model.get('domains').length == 0
      @$('.empty').show()
    else
      _.each @model.get('domains'), (domain) =>
        _.each @options.errors.domain || [], (message) =>
          domain.error = message if message.test /^#{domain.get('name')} /

        @_insert_entry(domain)

  _insert_entry: (domain) ->
    view = new Locomotive.Views.Site.DomainEntryView model: domain, parent_view: @

    (@_entry_views ||= []).push(view)

    @$('ul').append(view.render().el)





