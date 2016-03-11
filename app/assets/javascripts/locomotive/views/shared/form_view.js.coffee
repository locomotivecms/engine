Locomotive.Views.Shared ||= {}

class Locomotive.Views.Shared.FormView extends Backbone.View

  el: '.main'

  namespace: null

  events:
    'submit form':              'save'
    'ajax:aborted:required':    'show_empty_form_message'
    'keyup input, textarea':    'modifying'

  render: ->
    @inputs = []

    @display_active_nav()

    @register_unsaved_content()

    @enable_hover()

    @enable_simple_image_inputs()
    @enable_image_inputs()
    @enable_file_inputs()
    @enable_array_inputs()
    @enable_toggle_inputs()
    @enable_datetime_inputs()
    @enable_text_inputs()
    @enable_rte_inputs()
    @enable_markdown_inputs()
    @enable_tags_inputs()
    @enable_document_picker_inputs()
    @enable_select_inputs()
    @enable_color_inputs()

    return @

  register_unsaved_content: ->
    # reset the unsaved content since this is a new form
    window.unsaved_content = false

    @tokens = [
      PubSub.subscribe 'inputs.text_changed', => @modifying()
    ]

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
    @$('form button[type=submit], form input[type=submit]').button('loading')

  reset_state: ->
    @$('form button[type=submit], form input[type=submit]').button('reset')

  save: (event) ->
    window.unsaved_content = false
    @change_state()
    @record_active_tab()

  show_empty_form_message: (event) ->
    message = @$('form').data('blank-required-fields-message')

    Locomotive.notify message, 'error' if message?

    @reset_state()

  enable_hover: ->
    $('.form-group.input').hover ->
      $(this).addClass('hovered')
    , ->
      $(this).removeClass('hovered')

  enable_simple_image_inputs: ->
    self = @
    @$('.input.simple_image').each ->
      view = new Locomotive.Views.Inputs.SimpleImageView(el: $(@))
      view.render()
      self.inputs.push(view)

  enable_image_inputs: ->
    self = @
    @$('.input.image').each ->
      view = new Locomotive.Views.Inputs.ImageView(el: $(@))
      view.render()
      self.inputs.push(view)

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

  enable_datetime_inputs: ->
    @$('.input.date input[type=text], .input.date-time input[type=text]').each ->
      format    = $(@).data('format')
      datetime  = moment($(@).attr('value'), format)
      datetime  = null unless datetime.isValid()

      # https://github.com/Eonasdan/bootstrap-datetimepicker/issues/1290
      $(@).removeAttr('value').datetimepicker
        locale:       window.locale
        widgetParent: $(this).parents('.form-wrapper')
        format:       format
        defaultDate:  datetime

  enable_text_inputs: ->
    self = @
    @$('.input.text').each ->
      view = new Locomotive.Views.Inputs.TextView(el: $(@))
      view.render()
      self.inputs.push(view)

  enable_rte_inputs: ->
    self = @
    @$('.input.rte').each ->
      view = new Locomotive.Views.Inputs.RteView(el: $(@))
      view.render()
      self.inputs.push(view)

  enable_markdown_inputs: ->
    self = @
    @$('.input.markdown').each ->
      view = new Locomotive.Views.Inputs.MarkdownView(el: $(@))
      view.render()
      self.inputs.push(view)

  enable_color_inputs: ->
    @$('.input.color .input-group').colorpicker(container: false, align: 'right')

  enable_tags_inputs: ->
    @$('.input.tags input[type=text]').tagsinput()

  enable_select_inputs: ->
    @$('.input.select select:not(.disable-select2)').select2()

  enable_document_picker_inputs: ->
    self = @
    @$('.input.document_picker').each ->
      view = new Locomotive.Views.Inputs.DocumentPickerView(el: $(@))
      view.render()
      self.inputs.push(view)

  modifying: (event) ->
    window.unsaved_content = true

  remove: ->
    _.each @inputs, (view) -> view.remove()
    _.each @tokens, (token) -> PubSub.unsubscribe(token)

    @$('.input.select select:not(.disable-select2)').select2('destroy')
    @$('.input.tags input[type=text]').tagsinput('destroy')
    @$('.input.color .input-group').colorpicker('destroy')

  _stop_event: (event) ->
    event.stopPropagation() & event.preventDefault()
