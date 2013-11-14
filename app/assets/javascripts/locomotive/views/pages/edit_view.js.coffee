Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.EditView extends Locomotive.Views.Pages.FormView

  save: (event) ->
    event.stopPropagation() & event.preventDefault()

    @trigger_change_event_on_focused_inputs()

    form = $(event.target).trigger('ajax:beforeSend')

    @clear_errors()

    # store the previous editable elements in case we
    # need to use the content of these elements for
    # the new ones (same block and slug).
    editable_elements = _.clone @model.get('editable_elements')

    @model.save {},
      success: (model, response) =>
        form.trigger('ajax:complete')

        model._normalize()

        if model.get('template_changed') == true
          model.get('editable_elements').update_content_from(editable_elements)
          @reset_editable_elements()
        else
          @refresh_editable_elements()

        # refresh the show link
        fullpath = @model.get('localized_fullpaths')[window.content_locale]
        @$('#local-actions-bar > a.show').attr('href', "/#{fullpath}")

      error: (model, xhr) =>
        form.trigger('ajax:complete')

        errors = JSON.parse(xhr.responseText)

        @show_errors errors
