Locomotive.Views.ContentTypes ||= {}

class Locomotive.Views.ContentTypes.CustomFieldsView extends Backbone.View

  tagName: 'div'

  className: 'list'

  _entry_views = []

  events:
    'click .new-entry a.add': 'add_entry'
    'keypress .new-entry input[type=text]': 'add_on_entry_from_enter'

  initialize: ->
    _.bindAll(@, 'refresh_position_entries')

  render: ->
    $(@el).html(ich.custom_fields_list(@model.toJSON()))

    @render_entries()

    @make_list_sortable()

    return @

  make_list_sortable: ->
    @sortable_list = @$('> ul').sortable
      handle: '.handle'
      items:  'li.custom-field'
      axis:   'y'
      update: @refresh_position_entries

  refresh_position_entries: ->
    _.each @_entry_views, (view) ->
      view.model.set position: $(view.el).index()

  find_entry_view: (key) ->
    _.find @_entry_views, (view) ->
      if key.length > 3
        view.model.id == key
      else
        view.model.get('position') == parseInt(key)

  add_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    labelInput  = @$('> .new-entry input[name=label]')
    typeInput   = @$('> .new-entry select')

    if labelInput.val() != ''
      custom_field = new Locomotive.Models.CustomField label: labelInput.val(), type: typeInput.val()

      @model.get('entries_custom_fields').add(custom_field)

      @_insert_entry(custom_field)

      @$('> .empty').hide()

      @sortable_list.sortable('refresh')

      labelInput.val('') # reset for further entries

  add_on_entry_from_enter: (event) ->
    return if event.keyCode != 13
    @add_entry(event)

  remove_entry: (custom_field, view) ->
    if custom_field.isNew()
      @model.get('entries_custom_fields').remove(custom_field)
    else
      custom_field.set _destroy: true

    @_entry_views = _.reject @_entry_views, (_view) -> _view == view

    @refresh_position_entries()

    @$('> .empty').show() if @_entry_views.length == 0

  render_entries: ->
    if @model.get('entries_custom_fields').length == 0
      @$('> .empty').show()
    else
      @model.get('entries_custom_fields').each (custom_field) =>
        @_insert_entry(custom_field)

  _insert_entry: (custom_field) ->
    view = new Locomotive.Views.ContentTypes.CustomFieldEntryView model: custom_field, parent_view: @

    (@_entry_views ||= []).push(view)

    @$('> ul').append(view.render().el)

    @refresh_position_entries()