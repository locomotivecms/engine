Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.EditView extends Locomotive.Views.Shared.FormView

  el: '.content > .inner'

  initialize: ->
    super

    $('form.edit_page').on 'ajax:success', (event, data, status, xhr) =>
      @refresh_inputs $(data)

  refresh_inputs: ($html) ->
    @inputs = _.map @inputs, (view) =>
      return view unless view.need_refresh?

      dom_id    = $(view.el).attr('id')
      $new_el   = $html.find("##{dom_id}")

      view.replace $new_el
