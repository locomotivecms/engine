Locomotive.Views.ContentTypes ||= {}

class Locomotive.Views.ContentTypes.EditView extends Locomotive.Views.ContentTypes.FormView

  save: (event) ->
    @save_in_ajax event