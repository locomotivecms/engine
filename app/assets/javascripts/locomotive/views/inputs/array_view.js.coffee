Locomotive.Views.Inputs ||= {}

class Locomotive.Views.Inputs.ArrayView extends Backbone.View

  events:
    'click a.add':                'begin_add_item'
    'keypress input[type=text]':  'begin_add_item_from_enter'
    'click a.delete':             'delete_item'

  initialize: ->
    @$list          = @$('.list')
    @$new_field     = @$('.new-field input[type=text]')
    @$new_button    = @$('.new-field a')

    @template_url   = @$new_button.attr('href')

  render: ->
    @make_sortable()

  make_sortable: ->
    @$list.sortable
      items:        '> .item'
      handle:       '.draggable'
      axis:         'y'
      placeholder:  'sortable-placeholder'
      cursor:       'move'
      start:        (e, ui) ->
        ui.placeholder.html('<div class="inner">&nbsp;</div>')

  begin_add_item_from_enter: (event) ->
    return if event.keyCode != 13
    @begin_add_item(event)

  begin_add_item: (event) ->
    event.stopPropagation() & event.preventDefault()

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
    @$new_field.val('')

  delete_item: (event) ->
    $(event.target).parents('.item').remove()

    @hideEl(@$list) if @$list.find('> .item').size() == 0

  showEl: (el) -> el.removeClass('hide')
  hideEl: (el) -> el.addClass('hide')