Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.EditView extends Locomotive.Views.Shared.FormView

  el: '.content > .inner'

  render: ->
    super

    $('form.edit_page').on 'ajax:success', (event, data, status, xhr) =>
      if @need_reload?
        window.location.reload()
      else
        @refresh_inputs $(data)

    $('.info-row select[name=block]').select2().on 'change', (event) =>
      @filter_elements_by(event.val)

    # editable control elements
    $('.editable-elements .form-group.input.select select').select2().on 'change', (event) =>
      @need_reload = true

  refresh_inputs: ($html) ->
    @inputs = _.map @inputs, (view) =>
      return view unless view.need_refresh?

      dom_id    = $(view.el).attr('id')
      $new_el   = $html.find("##{dom_id}")

      view.replace $new_el if $new_el.size() > 0

  filter_elements_by: (block) ->
    @$('.editable-elements .form-group.input').each ->
      $el = $(this)

      if block == '' || (block == '_unknown' && $el.data('block') == '') || $el.data('block') == block
        $el.parent().show()
      else
        $el.parent().hide()
