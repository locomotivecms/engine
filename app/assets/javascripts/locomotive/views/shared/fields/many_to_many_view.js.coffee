Locomotive.Views.Shared ||= {}
Locomotive.Views.Shared.Fields ||= {}

class Locomotive.Views.Shared.Fields.ManyToManyView extends Locomotive.Views.Shared.Fields.RelationshipView

  tagName: 'div'

  className: 'list'

  events:
    'click .new-entry a.add':                   'add_entry'
    'keypress .new-entry input.selected-entry': 'add_entry'
    'click ul span.actions a.remove':           'remove_entry'

  template: ->
    ich["#{@options.name}_list"]

  entry_template: ->
    ich["#{@options.name}_entry"]

  initialize: ->
    _.bindAll(@, 'refresh_position_entries')

    @collection   = @model.get(@options.name)

  render: ->
    $(@el).html(@template()()).attr('id', "#{@model.paramRoot}_#{@options.name}_ids")

    @insert_entries()

    @make_entries_sortable()

    @enable_select2()

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

    # get the raw data of the selected entry
    data = @$('.new-entry .selected-entry').select2('data')

    return if !data? || _.isArray(data)

    # build a new instance of a content entry
    entry = new Locomotive.Models.ContentEntry(data)

    @insert_entry(entry)

    @$('.new-entry .selected-entry').select2('val', '')

  remove_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    if confirm($(event.target).closest('a').data('confirm'))
      entry = @get_entry_from_element($(event.target))
      @collection.remove(entry)

      $(event.target).closest('li').remove()
      @$('.empty').show() if @$('> ul > li').size() == 0

      @refresh_position_entries()

  enable_select2: ->
    $input  = @$('.new-entry .selected-entry')
    options = $input.data()

    super($input, options)

  #   $input.select2
  #     width:                '50%'
  #     minimumInputLength:   1
  #     quietMillis:          100
  #     allowClear:           true
  #     placeholder:          ' '
  #     ajax:
  #       url: options.url
  #       data: (term, page) ->
  #         q:    term
  #         page: page
  #       results: (data, page) =>
  #         results:  @build_results(data, options.groupBy)
  #         more:     data.length == options.perPage

  #     initSelection: (element, callback) -> null

  # build_results: (raw_data, group_by) ->
  #   _.tap [], (list) =>
  #     _.each raw_data, (data) =>
  #       unless @collection.get(data._id)?
  #         data.text = data._label

  #         if group_by?
  #           group_name = _.result(data, group_by)

  #           # does the group exist?
  #           group = _.find list, (_group) -> _group.text == group_name

  #           unless group?
  #             # build a new group
  #             group = { text: group_name, children: [] }
  #             list.push(group)

  #           group.children.push(data)
  #         else
  #           list.push(data)

  get_entry_from_element: (element) ->
    entry_html  = $(element).closest('li')
    id          = $(entry_html).data('data-entry-id')
    @collection.get(id)