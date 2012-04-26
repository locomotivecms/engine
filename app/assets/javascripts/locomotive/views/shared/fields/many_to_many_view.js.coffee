Locomotive.Views.Shared ||= {}
Locomotive.Views.Shared.Fields ||= {}

class Locomotive.Views.Shared.Fields.ManyToManyView extends Backbone.View

  tagName: 'div'

  className: 'list'

  events:
    'click .new-entry a.add':         'add_entry'
    'keypress .new-entry select':     'add_entry'
    'click ul span.actions a.remove': 'remove_entry'

  template: ->
    ich["#{@options.name}_list"]

  entry_template: ->
    ich["#{@options.name}_entry"]

  initialize: ->
    _.bindAll(@, 'refresh_position_entries')

    @collection   = @model.get(@options.name)
    @all_entries  = @options.all_entries

  render: ->
    $(@el).html(@template()())

    @insert_entries()

    @make_entries_sortable()

    @refresh_select_field()

    return @

  ui_enabled: ->
    @template()?

  insert_entries: ->
    if @collection.length > 0
      @collection.each (entry) => @insert_entry(entry)
    else
      @$('.empty').show()

  insert_entry: (entry) ->
    unless @collection.get(entry.get('_id'))?
      @collection.add(entry)

    @$('.empty').hide()
    entry_html = $(@entry_template()(label: entry.get('_label')))
    entry_html.data('data-entry-id', entry.id)
    @$('> ul').append(entry_html)

  make_entries_sortable: ->
    @sortable_list = @$('> ul').sortable
      handle: '.handle'
      items:  'li'
      axis:   'y'
      update: @refresh_position_entries

  refresh_position_entries: ->
    @$('> ul > li').each (index, entry_html) =>
      id    = $(entry_html).data('data-entry-id')
      entry = @collection.get(id)
      entry.set_attribute "__position", index

  add_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    entry_id  = @$('.new-entry select').val()
    entry     = @get_entry_from_id(entry_id)

    return unless entry?

    @insert_entry(entry)
    @refresh_select_field()

  remove_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    if confirm($(event.target).attr('data-confirm'))
      entry = @get_entry_from_element($(event.target))
      @collection.remove(entry)

      $(event.target).closest('li').remove()
      @$('.empty').show() if @$('> ul > li').size() == 0

      @refresh_position_entries() & @refresh_select_field()

  refresh_select_field: ->
    @$('.new-entry select optgroup, .new-entry select option').remove()

    _.each @all_entries, (entry_or_group) =>
      if _.isArray(entry_or_group.entries)
        group_html = $('<optgroup/>').attr('label', entry_or_group.name)

        _.each entry_or_group.entries, (entry) =>
          unless @collection.get(entry._id)?
            option = new Option(entry._label, entry._id, false)
            group_html.append(option)

        @$('.new-entry select').append(group_html)
      else
        unless @collection.get(entry_or_group._id)?
          option = new Option(entry_or_group._label, entry_or_group._id, false)
          @$('.new-entry select').append(option)

  get_entry_from_element: (element) ->
    entry_html  = $(element).closest('li')
    id          = $(entry_html).data('data-entry-id')
    @collection.get(id)

  get_entry_from_id: (id) ->
    entry = null

    _.each @all_entries, (entry_or_group) =>
      if _.isArray(entry_or_group.entries)
        entry ||= _.detect(entry_or_group.entries, (_entry) => _entry._id == id)
      else
        entry = entry_or_group if entry_or_group._id == id

    if entry?
      new Locomotive.Models.ContentEntry(entry)
    else
      null




