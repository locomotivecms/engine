Locomotive.Views.Pages ||= {}

class Locomotive.Views.Pages.NewView extends Locomotive.Views.Pages.FormView

  save: (event) ->
    @save_in_ajax event,
      on_success: (response, xhr) ->
        window.location.href = xhr.getResponseHeader('location')