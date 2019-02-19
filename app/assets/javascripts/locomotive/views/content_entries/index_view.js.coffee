Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.IndexView extends Backbone.View

  el: '.main'

  events:
    'click .content-entries-select-all': 'select_all_checkboxes'
    'click .content-entries-unselect-all': 'unselect_all_checkboxes'
    'change .item input[type=checkbox]': 'toggle_selector'

  initialize: ->
    @list_view = new Locomotive.Views.Shared.ListView(el: @$('.big-list'))

  render: ->
    @list_view.render()

  select_all_checkboxes: (event) ->
    @$('.item input[type=checkbox]').prop('checked', true)
    @show_unselect_all_button()

  unselect_all_checkboxes: (event) ->
    @$('.item input[type=checkbox]').prop('checked', false)
    @show_select_all_button()

  toggle_selector: (event) ->
    if !event.target.checked
      if @$('.item input[type=checkbox]:checked').size() == 0
        @show_select_all_button()
      else
        @show_unselect_all_button()
    else
      @show_unselect_all_button()

  show_select_all_button: ->
    $('.content-entries-unselect-all').addClass('hidden')
    $('.content-entries-select-all').removeClass('hidden')

  show_unselect_all_button: ->
    $('.content-entries-select-all').addClass('hidden')
    $('.content-entries-unselect-all').removeClass('hidden')

  remove: ->
    @list_view.remove()
    super()
