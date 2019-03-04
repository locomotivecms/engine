Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.BulkDeleteView extends Backbone.View

  el: '.main'

  events:
    'change .list-main-checkbox': 'tickOrUntickAll'
    'change .item input[type=checkbox]': 'tickOrUntick'

  tickOrUntickAll: (event) ->
    @$('.item input[type=checkbox]').prop('checked', event.target.checked)
    @refreshBulkDestroyFormState()

  tickOrUntick: (event) ->
    @$('.list-main-checkbox').prop('checked', false)
    @refreshBulkDestroyFormState()

  refreshBulkDestroyFormState: ->
    ids = []
    @$('.item input[type=checkbox]:checked').each(() -> ids.push($(this).val()))
    @$('.bulk-destroy-action input[name=ids]').val(ids.join(','))

    if @$('.item input[type=checkbox]:checked').size() > 0
      @$('.bulk-destroy-action').removeClass('hidden')
    else
      @$('.bulk-destroy-action').addClass('hidden')
