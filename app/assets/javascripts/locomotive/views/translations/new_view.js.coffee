Locomotive.Views.Translations ||= {}

class Locomotive.Views.Translations.NewView extends Locomotive.Views.Translations.FormView

  save: (event) ->
    @save_in_ajax event,
      on_success: (response, xhr) ->
        window.location.href = xhr.getResponseHeader('location')