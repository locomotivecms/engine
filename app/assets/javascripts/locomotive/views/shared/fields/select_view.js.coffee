Locomotive.Views.Shared ||= {}
Locomotive.Views.Shared.Fields ||= {}

class Locomotive.Views.Shared.Fields.SelectView extends Backbone.View

  el: '#edit-select-option-entries'

  select_options_view: null

  initialize: ->
    _.bindAll(@, 'save', 'on_save')

    @create_dialog()

    super()

  render: ->
    @render_select_options_view()

    @open()

  render_for: (name, callback) ->
    @name = name; @on_save_callback = callback

    @custom_field = @model.find_entries_custom_field(@name)

    @render()

  create_dialog: ->
    @dialog = $(@el).dialog
      autoOpen: false
      modal:    true
      zIndex:   window.application_view.unique_dialog_zindex()
      width:    770,
      create: (event, ui) =>
        $(@el).prev().find('.ui-dialog-title').html(@$('h2').html())
        @$('h2').remove()

        @$form =          @$('.placeholder').formSubmitNotification() # fake form
        @$buttons_pane =  @$('.dialog-actions').appendTo($(@el).parent()).addClass('ui-dialog-buttonpane ui-widget-content ui-helper-clearfix')

        @$buttons_pane.find('#close-link').click (event) => @close(event)
        @$buttons_pane.find('input[type=submit]').click @save

      open: (event, ui, extra) =>
        $(@el).dialog('overlayEl').bind 'click', => @close()
        # nothing to do

  save: (event) ->
    event.stopPropagation() & event.preventDefault()

    @$form.trigger 'ajax:beforeSend'
    $.rails.disableFormElements(@$buttons_pane)

    @model.save {}, success: @on_save, error: @on_save

  on_save: (model, response) =>
    $.rails.enableFormElements(@$buttons_pane)
    model._normalize()

    # the field has been changed as well as its select options, so get a fresh copy.
    @custom_field = model.find_entries_custom_field(@custom_field.get('name'))

    @$form.trigger('ajax:complete')
    @on_save_callback(@custom_field.get('select_options').sortBy((option) -> option.get('position'))) if @on_save_callback?
    @close()

  render_select_options_view: ->
    @select_options_view.remove() if @select_options_view?

    @select_options_view = new Locomotive.Views.ContentTypes.SelectOptionsView
      model:      @custom_field
      collection: @custom_field.get('select_options')

    @$('.placeholder').append(@select_options_view.render().el)

  open: ->
    $(@el).dialog('open')

  close: (event) ->
    event.stopPropagation() & event.preventDefault() if event?
    $(@el).dialog('overlayEl').unbind('click')
    $(@el).dialog('close')

  center: ->
    $(@el).dialog('option', 'position', 'center')

