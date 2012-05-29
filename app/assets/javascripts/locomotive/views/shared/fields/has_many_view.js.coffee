Locomotive.Views.Shared ||= {}
Locomotive.Views.Shared.Fields ||= {}

class Locomotive.Views.Shared.Fields.HasManyView extends Backbone.View

  tagName: 'div'

  className: 'list'

  events:
    'click p.actions a.add':          'open_new_entry_view'
    'click ul span.actions a.edit':   'edit_entry'
    'click ul span.actions a.remove': 'remove_entry'

  template: ->
    ich["#{@options.name}_list"]

  entry_template: ->
    ich["#{@options.name}_entry"]

  initialize: ->
    _.bindAll(@, 'refresh_position_entries')

    @collection = @model.get(@options.name)

    @build_target_entry_view()

  render: ->
    $(@el).html(@template()())

    @insert_entries()

    @make_entries_sortable()

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
      entry.set_attribute "position_in_#{@options.inverse_of}", index

  build_target_entry_view: ->
    @target_entry_view = new Locomotive.Views.ContentEntries.PopupFormView
      el:           $("##{@options.name}-template-entry")
      parent_view:  @
      model:        @options.new_entry.clone() # by default, it does not matter

    @target_entry_view.render()

  edit_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    entry = @get_entry_from_element($(event.target))

    @target_entry_view.reset(entry)
    @target_entry_view.open()

  update_entry: (entry) ->
    entry_html = $(_.detect @$('> ul > li'), (_entry_html) -> $(_entry_html).data('data-entry-id') == entry.id)

    @collection.get(entry.id).set(entry.attributes) # sync

    new_entry_html = $(@entry_template()(label: entry.get('_label')))
    new_entry_html.data('data-entry-id', entry.id)

    entry_html.replaceWith(new_entry_html)

  insert_or_update_entry: (entry) ->
    if @collection.get(entry.id)?
      @update_entry(entry)
    else
      @insert_entry(entry)

  remove_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    if confirm($(event.target).attr('data-confirm'))
      entry = @get_entry_from_element($(event.target))
      entry.set _destroy: true

      $(event.target).closest('li').remove()
      @$('.empty').show() if @$('> ul > li').size() == 0
      @refresh_position_entries()

  open_new_entry_view: (event) ->
    event.stopPropagation() & event.preventDefault()

    @target_entry_view.reset(@options.new_entry.clone())
    @target_entry_view.open()

  get_entry_from_element: (element) =>
    entry_html  = $(element).closest('li')
    id          = $(entry_html).data('data-entry-id')
    @collection.get(id)





