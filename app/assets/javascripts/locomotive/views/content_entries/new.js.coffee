Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.NewView extends Locomotive.Views.ContentEntries.FormView

  save: (event) ->
    @save_in_ajax event,
      on_success: (response, xhr) ->
        window.location.href = xhr.getResponseHeader('location')
