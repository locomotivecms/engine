Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.EditView extends Locomotive.Views.Pages.FormView

  save: (event) ->
    event.stopPropagation() & event.preventDefault()

    @clear_errors()

    console.log('saving')

    @model.save {},
      success: (model, response, xhr) =>
        model._normalize()

        $.growl('success', xhr.getResponseHeader('X-Message'))

        if model.get('template_changed') == true
          @reset_editable_elements()
        else
          @refresh_editable_elements()

      error: (model, xhr) =>
        errors = JSON.parse(xhr.responseText)

        @show_errors errors

        $.growl('error', xhr.getResponseHeader('X-Message'))



