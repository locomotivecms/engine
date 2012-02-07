Locomotive.Views.ContentTypes ||= {}

class Locomotive.Views.ContentTypes.NewView extends Locomotive.Views.ContentTypes.FormView

  save: (event) ->
    @save_in_ajax event,
      on_success: (response, xhr) ->
        window.location.href = xhr.getResponseHeader('location')

  enable_liquid_editing: ->
    true # do nothing