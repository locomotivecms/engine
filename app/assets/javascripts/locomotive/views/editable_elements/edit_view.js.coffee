Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.EditView extends Locomotive.Views.Shared.FormView

  el: '.content-main > .actionbar .content'

  events: _.extend {}, Locomotive.Views.Shared.FormView.prototype.events,
    'click .form-group.rte label':  'select_editable_text'
    'click .form-group.text label': 'select_editable_text'

  initialize: ->
    _.bindAll(@, 'highlight_form_group')

    @tokens = [
      PubSub.subscribe 'editable_elements.highlighted_text', @highlight_form_group
    ]

  render: ->
    super

    $('form.edit_page').on 'ajax:success', (event, data, status, xhr) =>
      if @need_reload?
        window.location.reload()
      else
        @refresh_inputs $(data)

    $('.info-row select[name=block]').select2().on 'change', (event) =>
      PubSub.publish 'editable_elements.block_selected', name: $(event.target).val()
      @filter_elements_by($(event.target).val())

    # editable control elements
    $('.editable-elements .form-group.input.select select').select2().on 'change', (event) =>
      @need_reload = true

  select_editable_text: (event) ->
    element_id = $(event.target).parents('.form-group').attr('id').replace('editable-text-', '')
    PubSub.publish 'editable_elements.form_group_selected', element_id: element_id

  highlight_form_group: (msg, data) ->
    $form_group = $(@el).find("#editable-text-#{data.element_id}")

    return false if $form_group.size() == 0

    @filter_elements_by('')

    highlight_effect = =>
      $form_group.clearQueue().queue (next) ->
        $(this).addClass('highlighted')
        next()
      .delay(200).queue (next) ->
        $(this).removeClass('highlighted').find('input[type=text],textarea').trigger('highlight')
        next()

    # scroll to the form group and then highlight the textarea/input/editor
    $parent = @$('.scrollable')
    offset  = $form_group.position().top

    if offset == 0
      $parent.animate { scrollTop: 0 }, 500, 'swing', highlight_effect
    else if offset < 0 || offset > $parent.height()
      offset = $parent.scrollTop() + offset if offset < 0
      $parent.animate { scrollTop: offset }, 500, 'swing', highlight_effect
    else
      highlight_effect()

  refresh_inputs: ($html) ->
    @inputs = _.map @inputs, (view) =>
      return view unless view.need_refresh?

      dom_id    = $(view.el).attr('id')
      $new_el   = $html.find("##{dom_id}")

      view.replace $new_el

      view

  filter_elements_by: (block) ->
    @$('.editable-elements .form-group.input').each ->
      $el = $(this)

      if block == '' || (block == '_unknown' && $el.data('block') == '') || $el.data('block') == block
        $el.parent().show()
      else
        $el.parent().hide()

  remove: ->
    super
    _.each @tokens, (token) -> PubSub.unsubscribe(token)
