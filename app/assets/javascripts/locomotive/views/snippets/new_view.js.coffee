Locomotive.Views.Snippets ||= {}

class Locomotive.Views.Snippets.NewView extends Locomotive.Views.Snippets.FormView

  save: (event) ->
    @save_in_ajax event,
      on_success: (response, xhr) ->
        window.location.href = xhr.getResponseHeader('location')