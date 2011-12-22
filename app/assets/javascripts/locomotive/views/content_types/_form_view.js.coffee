#= require ../shared/form_view

Locomotive.Views.ContentTypes ||= {}

class Locomotive.Views.ContentTypes.FormView extends Locomotive.Views.Shared.FormView

  el: '#content'

  events:
    'submit': 'save'

  initialize: ->
    @model = new Locomotive.Models.ContentType(@options.content_type)

    Backbone.ModelBinding.bind @

  render: ->
    super()

    @render_custom_fields()

    @slugify_name() # slugify the slug field from name

    @enable_liquid_editing() # turn textarea into editable liquid code zone

    @enable_public_form_checkbox()

    @enable_order_by_toggler()

    return @

  render_custom_fields: ->
    @custom_fields_view = new Locomotive.Views.ContentTypes.CustomFieldsView model: @model

    @$('#custom_fields_input').append(@custom_fields_view.render().el)

  slugify_name: ->
    @$('#content_type_name').slugify(target: @$('#content_type_slug'), sep: '_')

  enable_liquid_editing: ->
    input = @$('#content_type_raw_item_template')
    @editor = CodeMirror.fromTextArea input.get()[0],
      mode:             'liquid'
      autoMatchParens:  false
      lineNumbers:      false
      passDelay:        50
      tabMode:          'shift'
      theme:            'default medium'
      onChange: (editor) => @model.set(raw_item_template: editor.getValue())

  enable_public_form_checkbox: ->
    @_enable_checkbox 'public_form_enabled',
      on_callback: => @$('#content_type_public_form_accounts_input').show()
      off_callback: => @$('#content_type_public_form_accounts_input').hide()

  enable_order_by_toggler: ->
    @$('#content_type_order_by_input').bind 'change', (event) =>
      target = @$('#content_type_order_direction_input')
      if $(event.target).val() == '_position_in_list'
        target.hide()
      else
        target.show()

  show_error: (attribute, message, html) ->
    if attribute == 'contents_custom_fields'
      return if _.isEmpty(message)
      for _message, index in message
        @custom_fields_view._entry_views[index].show_error(_message[0])
    else
      super

  remove: ->
    @custom_fields_view.remove()
    super

