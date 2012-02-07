Locomotive.Views.Snippets ||= {}

class Locomotive.Views.Snippets.EditView extends Locomotive.Views.Snippets.FormView

  save: (event) ->
    @save_in_ajax event