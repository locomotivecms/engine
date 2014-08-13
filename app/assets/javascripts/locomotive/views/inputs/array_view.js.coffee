Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.ArrayView extends Backbone.View

  events:
    'click a.add':                'begin_add_item'
    'keypress input[type=text]':  'begin_add_item_from_enter'
    'click a.delete':             'delete_item'

  initialize: ->
    @$list          = @$('.list')
    @$text_field    = @$('.new-field input[type=text]')
    @$select_field  = @$('.new-field select')
    @$new_field     = if @$text_field.size() == 1 then @$text_field else @$select_field
    @$new_button    = @$('.new-field a')

    @template_url   = @$new_button.attr('href')

  render: ->
    @make_sortable()
    @render_select()

  make_sortable: ->
    @$list.sortable
      items:        '> .item'
      handle:       '.draggable'
      axis:         'y'
      placeholder:  'sortable-placeholder'
      cursor:       'move'
      start:        (e, ui) ->
        ui.placeholder.html('<div class="inner">&nbsp;</div>')

  render_select: ->
    @$select_field.select2
      containerCssClass:  'form-control'
      formatResult:       @format_select_result
      formatSelection:    @format_select_result
      escapeMarkup:       (m) -> { m }

  format_select_result: (state) ->
    return state.text unless state.id?

    display = $(state.element).data('display')

    if display? then display else state.text

  begin_add_item_from_enter: (event) ->
    return if event.keyCode != 13
    @begin_add_item(event)

  begin_add_item: (event) ->
    event.stopPropagation() & event.preventDefault()

    return unless @is_unique()

    data = {}
    data[@$new_field.attr('name')] = @$new_field.val()

    $.ajax
      url:      @template_url
      data:     data
      success:  (response) => @add_item(response)

  add_item: (html) ->
    # add to the list of items
    @$list.append(html)
    @showEl(@$list)

    # refresh the text field
    @reset_text_field()

  delete_item: (event) ->
    $link = $(event.target).closest('a')

    return if $link.attr('href') != '#'

    $link.parents('.item').remove()

    @hideEl(@$list) if @$list.find('> .item').size() == 0

  is_unique: ->
    _.indexOf(@get_ids(), @$new_field.val()) == -1

  get_ids: ->
    _.map @$list.find('> .item'), (item, i) -> $(item).data('id')

  reset_text_field: ->
    if @$text_field.size() == 1
      @$new_field.val('')

  showEl: (el) -> el.removeClass('hide')
  hideEl: (el) -> el.addClass('hide')