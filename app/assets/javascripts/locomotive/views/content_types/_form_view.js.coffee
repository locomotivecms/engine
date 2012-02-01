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

    @enable_public_submission_checkbox()

    @enable_order_by_toggler()

    return @

  render_custom_fields: ->
    @custom_fields_view = new Locomotive.Views.ContentTypes.CustomFieldsView model: @model, inverse_of_list: @options.inverse_of_list

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

  enable_public_submission_checkbox: ->
    @_enable_checkbox 'public_submission_enabled',
      on_callback: => @$('#content_type_public_submission_accounts_input').show()
      off_callback: => @$('#content_type_public_submission_accounts_input').hide()

  enable_order_by_toggler: ->
    @$('#content_type_order_by_input').bind 'change', (event) =>
      target = @$('#content_type_order_direction_input')
      if $(event.target).val() == '_position'
        target.hide()
      else
        target.show()

  show_error: (attribute, message, html) ->
    if attribute != 'entries_custom_fields'
      super
    else
      return if _.isEmpty(message)

      _.each _.keys(message), (key) =>
        _messages = message[key]

        if key == 'base'
          html = $("<div class=\"inline-errors\"><p>#{_messages[0]}</p></div>")
          @$('#custom_fields_input .list').after(html)
        else
          view = @custom_fields_view.find_entry_view(key)
          view.show_error(_messages[0]) if view?

  remove: ->
    @custom_fields_view.remove()
    super

