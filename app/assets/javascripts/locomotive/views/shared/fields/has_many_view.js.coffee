Locomotive.Views.Shared ||= {}
Locomotive.Views.Shared.Fields ||= {}

class Locomotive.Views.Shared.Fields.HasManyView extends Backbone.View

  tagName: 'div'

  className: 'list'

  events:
    'click ul span.actions a.remove': 'remove_entry'

  template: ->
    ich["#{@options.name}_list"]

  entry_template: ->
    ich["#{@options.name}_entry"]

  initialize: ->
    _.bindAll(@, 'refresh_position_entries')

    @collection = @model.get(@options.name)

    window.model = @model
    window.bar  = @collection

  render: ->
    $(@el).html(@template()())

    @insert_entries()

    @make_entries_sortable()

    return @

  insert_entries: ->
    if @collection.length > 0
      @collection.each (entry) => @insert_entry(entry)
    else
      @$('.empty').show()

  insert_entry: (entry) ->
    @$('.empty').hide()
    entry_html = $(@entry_template()(label: entry.get('_label')))
    entry_html.data('data-entry-cid', entry.cid)
    @$('> ul').append(entry_html)

  make_entries_sortable: ->
    @sortable_list = @$('> ul').sortable
      handle: '.handle'
      items:  'li'
      axis:   'y'
      update: @refresh_position_entries

  refresh_position_entries: ->
    @$('> ul > li').each (index, entry_html) =>
      cid   = $(entry_html).data('data-entry-cid')
      entry = @collection.getByCid(cid)
      entry.set_attribute "position_in_#{@options.inverse_of}", index

  remove_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    if confirm($(event.target).attr('data-confirm'))
      entry_html  = $(event.target).closest('li')
      cid         = $(entry_html).data('data-entry-cid')
      entry       = @collection.getByCid(cid)
      entry.set _destroy: true

      entry_html.remove()
      @$('.empty').show() if @$('> ul > li').size() == 0
      @refresh_position_entries()

