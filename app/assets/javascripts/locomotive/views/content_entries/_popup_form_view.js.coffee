#= require ../shared/form_view

Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.PopupFormView extends Locomotive.Views.ContentEntries.FormView

  initialize: ->
    @create_dialog()

    super()

  render: ->
    super()

    return @

  save: (event) ->
    @save_in_ajax event,
      headers:  { 'X-Flash': true }
      on_success: (response, xhr) =>
        entry = new Locomotive.Models.ContentEntry(response)
        @options.parent_view.insert_or_update_entry(entry)
        @close()

  create_dialog: ->
    @dialog = $(@el).dialog
      autoOpen: false
      modal:    true
      zIndex:   window.application_view.unique_dialog_zindex()
      width:    770,
      create: (event, ui) =>
        $(@el).prev().find('.ui-dialog-title').html(@$('h2').html())
        @$('h2').remove()
        actions = @$('.dialog-actions').appendTo($(@el).parent()).addClass('ui-dialog-buttonpane ui-widget-content ui-helper-clearfix')

        actions.find('#close-link').click (event) => @close(event)
        actions.find('input[type=submit]').click (event) =>
          # since the submit buttons are outside the form, we have to mimic the behaviour of a basic form
          $form = @el.find('form'); $buttons_pane = $(event.target).parent()

          $.rails.disableFormElements($buttons_pane)

          $form.trigger('submit').bind 'ajax:complete', => $.rails.enableFormElements($buttons_pane)

      open: (event, ui, extra) =>
        $(@el).dialog('overlayEl').bind 'click', => @close()
        # nothing to do

  open: ->
    parent_el = $(@el).parent()
    if @model.isNew()
      parent_el.find('.edit-section').hide()
      parent_el.find('.new-section').show()
    else
      parent_el.find('.new-section').hide()
      parent_el.find('.edit-section').show()

    @clear_errors()

    $(@el).dialog('open')

  close: (event) ->
    event.stopPropagation() & event.preventDefault() if event?
    @clear_errors()
    $(@el).dialog('overlayEl').unbind('click')
    $(@el).dialog('close')

  center: ->
    $(@el).dialog('option', 'position', 'center')

  reset: (entry) =>
    @model.set entry.attributes

    if entry.isNew()
      @model.id = null
      super()
    else
      @refresh()

  slugify_label_field: ->
    # disabled in a popup form

  enable_has_many_fields: ->
    # disabled in a popup form

  enable_many_to_many_fields: ->
    # disabled in a popup form

  tinyMCE_settings: ->
    _.extend { language: window.locale }, window.Locomotive.tinyMCE.popupSettings
