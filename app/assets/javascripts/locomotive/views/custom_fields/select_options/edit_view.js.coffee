Locomotive.Views.CustomFields.SelectOptions ||= {}

class Locomotive.Views.CustomFields.SelectOptions.EditView extends Locomotive.Views.Shared.FormView

  el: '.main'

  events:
    'click .buttons .edit':     'start_inline_editing'
    'click .editable .apply':   'apply_inline_editing'
    'click .editable .cancel':  'cancel_inline_editing'

  start_inline_editing: (event) ->
    @_stop_event(event)
    $row            = $(event.target).parents('.inner-row')
    $label          = $row.find('.editable > span').addClass('hide')
    $input          = $label.next('input').removeClass('hide')
    $button         = $input.next('.btn').removeClass('hide')
    $cancel_button  = $button.next('.btn').removeClass('hide')
    $input.data('previous', $input.val())

  apply_inline_editing: (event) ->
    @_stop_event(event)
    $button         = $(event.target).closest('.btn').addClass('hide')
    $cancel_button  = $button.next('.btn').addClass('hide')
    $input          = $button.prev('input').addClass('hide')
    $label          = $input.prev('span').html($input.val()).removeClass('hide')

  cancel_inline_editing: (event) ->
    @_stop_event(event)
    $cancel_button  = $(event.target).closest('.btn').addClass('hide')
    $button         = $cancel_button.prev('.btn').addClass('hide')
    $input          = $button.prev('input').addClass('hide')
    $input.val($input.data('previous'))
    $label          = $input.prev('span').html($input.val()).removeClass('hide')

  mark_as_destroyed: (event) ->
    $destroy_input = $(event.target).parents('.item').find('.mark-as-destroyed')

    if $destroy_input.size() > 0
      $destroy_input.val('1')






