Locomotive.Views.ThemeAssets ||= {}

class Locomotive.Views.ThemeAssets.NewView extends Locomotive.Views.ThemeAssets.FormView

  save: (event) ->
    @save_in_ajax event,
      on_success: (response, xhr) ->
        window.location.href = xhr.getResponseHeader('location')