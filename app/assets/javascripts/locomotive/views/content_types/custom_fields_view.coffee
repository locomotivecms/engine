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
      handle: 'span.handle'
      items:  'li.custom-field'
      axis:   'y'
      update: @refresh_position_entries

  refresh_position_entries: ->
    _.each @_entry_views, (view) ->
      view.model.set position: $(view.el).index()

  add_entry: (event) ->
    event.stopPropagation() & event.preventDefault()

    labelInput  = @$('.new-entry input[name=label]')
    typeInput   = @$('.new-entry select')

    if labelInput.val() != ''
      custom_field = new Locomotive.Models.CustomField label: labelInput.val(), type: typeInput.val()

      window.bar = custom_field

      @model.get('contents_custom_fields').add(custom_field)

      @_insert_entry(custom_field)

      @$('.empty').hide()

      @sortable_list.sortable('refresh')

      labelInput.val('') # reset for further entries

  add_on_entry_from_enter: (event) ->
    return if event.keyCode != 13
    @add_entry(event)

  remove_entry: (custom_field, view) ->
    @_entry_views = _.reject @_entry_views, (_view) -> _view == view
    @model.get('contents_custom_fields').remove(custom_field)

    @refresh_position_entries()

    @$('.empty').show() if @model.get('contents_custom_fields').length == 0

  render_entries: ->
    if @model.get('contents_custom_fields').length == 0
      @$('.empty').show()
    else
      @model.get('contents_custom_fields').each (custom_field) =>
        @_insert_entry(custom_field)

  _insert_entry: (custom_field) ->
    view = new Locomotive.Views.ContentTypes.CustomFieldEntryView model: custom_field, parent_view: @

    (@_entry_views ||= []).push(view)

    @$('ul').append(view.render().el)

    @refresh_position_entries()

  #
  # show_errors: ->
  #   _.each @options.errors.domain || [], (message) => @show_error(message)
  #
  # show_error: (message) ->
  #   _.each (@_entry_views || []), (view) ->
  #     if new RegExp("^#{view.model.get('name')}").test message
  #       html = $('<span></span>').addClass('inline-errors').html(message)
  #       view.$('input[type=text].path').after(html)


