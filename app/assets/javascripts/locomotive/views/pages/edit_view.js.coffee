Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.EditView extends Locomotive.Views.Pages.FormView

  save: (event) ->
    event.stopPropagation() & event.preventDefault()

    @clear_errors()

    @model.save {},
      success: (model, response, xhr) =>
        model._normalize()

        if model.get('template_changed') == true
          @reset_editable_elements()
        else
          @refresh_editable_elements()

      error: (model, xhr) =>
        errors = JSON.parse(xhr.responseText)

        @show_errors errors



