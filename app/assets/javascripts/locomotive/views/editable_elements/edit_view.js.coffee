Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.EditView extends Locomotive.Views.Shared.FormView

  el: '.content > .inner'

  render: ->
    super

    $('form.edit_page').on 'ajax:success', (event, data, status, xhr) =>
      @refresh_inputs $(data)

    $('.info-row select[name=block]').select2().on 'change', (event) =>
      @filter_elements_by(event.val)

  refresh_inputs: ($html) ->
    @inputs = _.map @inputs, (view) =>
      return view unless view.need_refresh?

      dom_id    = $(view.el).attr('id')
      $new_el   = $html.find("##{dom_id}")

      view.replace $new_el

  filter_elements_by: (block) ->
    _.each @inputs, (view) ->
      $el = $(view.el)

      if block == '' || (block == '_unknown' && $el.data('block') == '') || $el.data('block') == block
        $el.show()
      else
        $el.hide()
