Locomotive.Views.ContentTypes ||= {}

class Locomotive.Views.ContentTypes.SelectOptionsView extends Backbone.View

  tagName: 'div'

  className: 'list'

  events:
    'click a.add':      'add_entry'
    'click span.name':  'edit_entry'
    'click a.remove':   'remove_entry'
    'click a.drag':     'do_nothing'

  initialize: ->
    _.bindAll(@, 'refresh_position_entries', '_insert_entry')

    @collection.bind 'add', @_insert_entry

  render: ->
    $(@el).html(ich.select_options_list())

    @prompt_message = @$('> ul').data('prompt')

    @render_entries()

    @make_list_sortable()

    return @

  render_entries: ->
    @collection.each @_insert_entry

  make_list_sortable: ->
    @sortable_list = @$('> ul').sortable
      handle: 'a.drag'
      items:  'li.entry'
      update: @refresh_position_entries

  refresh_position_entries: ->
    @$('> ul li.entry').each (index, view_dom) =>
      select_option = @collection.getByCid($(view_dom).data('cid'))
      select_option.set position: index

  do_nothing: (event) ->
    event.stopPropagation() & event.preventDefault()

  add_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    name = prompt(@prompt_message)

    if name != ''
      @collection.add [{ name: name }]

  edit_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    span          = $(event.target)
    view_dom      = span.closest('li')
    select_option = @collection.getByCid(view_dom.data('cid'))

    if (name = prompt(@prompt_message, select_option.get('name'))) != ''
      select_option.set(name: name)
      span.html(name)

  remove_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    link          = $(event.target)
    view_dom      = link.closest('li')
    select_option = @collection.getByCid(view_dom.data('cid'))

    if confirm(link.data('confirm'))
      if select_option.isNew()
        @collection.remove(select_option)
      else
        select_option.set _destroy: true

      view_dom.remove()

  _insert_entry: (select_option) ->
    view_dom = ich.select_option_entry(select_option.toJSON())

    view_dom.data('cid', select_option.cid)

    @$('> ul').append(view_dom)

    @refresh_position_entries