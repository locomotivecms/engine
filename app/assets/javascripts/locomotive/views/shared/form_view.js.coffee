Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.FormView extends Backbone.View

  el: '.main'

  namespace: null

  inputs: []

  events:
    'submit form': 'save'

  render: ->
    @display_active_nav()

    @enable_hover()

    @enable_file_inputs()
    @enable_array_inputs()
    @enable_toggle_inputs()
    @enable_date_inputs()
    @enable_datetime_inputs()
    @enable_rte_inputs()
    @enable_tags_inputs()
    @enable_document_picker_inputs()

    return @

  display_active_nav: ->
    url = document.location.toString()
    if url.match('#')
      name = url.split('#')[1]
      @$(".nav-tabs a[href='##{name}']").tab('show')

  record_active_tab: ->
    if $('form .nav-tabs li.active a').size() > 0
      tab_name = $('form .nav-tabs li.active a').attr('href').replace('#', '')
      @$('#active_tab').val(tab_name)

  change_state: ->
    @$('form button[type=submit]').button('loading')

  reset_state: ->
    @$('form button[type=submit]').button('reset')

  save: (event) ->
    @change_state()
    @record_active_tab()

  enable_hover: ->
    $('.form-group.input').hover ->
      $(this).addClass('hovered')
    , ->
      $(this).removeClass('hovered')

  enable_file_inputs: ->
    self = @
    @$('.input.file').each ->
      view = new Locomotive.Views.Inputs.FileView(el: $(@))
      view.render()
      self.inputs.push(view)

  enable_array_inputs: ->
    self = @
    @$('.input.array').each ->
      view = new Locomotive.Views.Inputs.ArrayView(el: $(@))
      view.render()
      self.inputs.push(view)

  enable_toggle_inputs: ->
    @$('.input.toggle input[type=checkbox]').each ->
      $toggle = $(@)
      $toggle.data('label-text', (if $toggle.is(':checked') then $toggle.data('off-text') else $toggle.data('on-text')))
      $toggle.bootstrapSwitch
        onSwitchChange: (event, state) ->
          $toggle.data('bootstrap-switch').labelText((if state then $toggle.data('off-text') else $toggle.data('on-text')))

  enable_date_inputs: ->
    @$('.input.date input[type=text]').each ->
      $(@).datetimepicker
        language: window.content_locale
        pickTime: false
        widgetParent: '.main'
        format: $(@).data('format')

  enable_datetime_inputs: ->
    @$('.input.date-time input[type=text]').each ->
      $(@).datetimepicker
        language: window.content_locale
        pickTime: true
        widgetParent: '.main'
        use24hours: true
        useseconds: false
        format: $(@).data('format')

  enable_rte_inputs: ->
    self = @
    @$('.input.rte').each ->
      view = new Locomotive.Views.Inputs.RteView(el: $(@))
      view.render()
      self.inputs.push(view)

  enable_tags_inputs: ->
    @$('.input.tags input[type=text]').tagsinput()

  enable_document_picker_inputs: ->
    self = @
    @$('.input.document_picker').each ->
      view = new Locomotive.Views.Inputs.DocumentPickerView(el: $(@))
      view.render()
      self.inputs.push(view)

  remove: ->
    _.each @inputs.each, (view) -> view.remove()
    @$('.input.tags input[type=text]').tagsinput('destroy')

  _stop_event: (event) ->
    event.stopPropagation() & event.preventDefault()
