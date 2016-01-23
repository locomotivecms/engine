Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.ArrayView extends Backbone.View

  events:
    'click a.add':                'begin_add_item'
    'keypress input[type=text]':  'begin_add_item_from_enter'
    'click a.delete':             'delete_item'

  initialize: ->
    @$list          = @$('.list')
    @$new_input     = @$('.new-field .input')
    @$new_button    = @$('.new-field a')

    @template_url   = @$new_button.attr('href')

  render: ->
    @make_sortable()
    @make_selectable()
    @hide_if_empty()

  make_sortable: ->
    @$list.sortable
      items:        '> .item'
      handle:       '.draggable'
      axis:         'y'
      placeholder:  'sortable-placeholder'
      cursor:       'move'
      start:        (e, ui) ->
        ui.placeholder.html('<div class="inner">&nbsp;</div>')
      update:       (e, ui) =>
        @$list.find('> .item:not(".hide")').each (index) ->
          $(this).find('.position-in-list').val(index)

  make_selectable: ->
    return if @$new_input.prop('tagName') != 'SELECT'

    if @$new_input.data('list-url')?
      @make_remote_selectable()
    else
      @make_simple_selectable()

  make_remote_selectable: ->
    Select2Helpers.build @$new_input
    @$new_input.on 'change', (e) => @begin_add_item(e)

  make_simple_selectable: ->
    @$new_input.select2
      templateResult:       @format_select_result
      templateSelection:    @format_select_result

  format_select_result: (state) ->
    return state.text unless state.id?

    display = $(state.element).data('display')

    $("<span>#{if display? then display else state.text}</span>")

  begin_add_item_from_enter: (event) ->
    return if event.keyCode != 13
    @begin_add_item(event)

  begin_add_item: (event) ->
    event.stopPropagation() & event.preventDefault()

    return unless @is_unique()

    data = {}
    data[@$new_input.attr('name')] = @$new_input.val()

    $.ajax
      url:      @template_url
      data:     data
      success:  (response) => @add_item(response)

  add_item: (html) ->
    # add to the list of items
    @$list.append(html)
    @showEl(@$list)

    # refresh the text field
    @reset_input_field()

  delete_item: (event) ->
    $link = $(event.target).closest('a')

    # call the url directly
    return if $link.attr('href') != '#'

    $item           = $link.parents('.item')
    $destroy_input  = $item.find('.mark-as-destroyed')

    if $destroy_input.size() > 0
      # mark item as destroyed and hide the item
      $destroy_input.val('1')
      $item.addClass('hide')

      @$list.find('> .item.last-child').removeClass('last-child')
      @$list.find('> .item:not(".hide"):last').addClass('last-child')
    else
      # remove the item from the dom
      $item.remove()

    # do not display the list if no visible items
    @hide_if_empty()

  hide_if_empty: ->
    if @$list.find('> .item:not(".hide")').size() == 0
      @hideEl(@$list)

      if @$list.hasClass('new-input-disabled')
        $(@el).find('> .form-wrapper').hide()

  is_unique: ->
    _.indexOf(@get_ids(), @$new_input.val()) == -1

  get_ids: ->
    _.map @$list.find('> .item'), (item, i) -> $(item).data('id')

  reset_input_field: ->
    @$new_input.val(null).trigger('change')

  showEl: (el) -> el.removeClass('hide')
  hideEl: (el) -> el.addClass('hide')
