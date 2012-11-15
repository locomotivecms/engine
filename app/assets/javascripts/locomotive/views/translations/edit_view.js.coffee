Locomotive.Views.Translations ||= {}

class Locomotive.Views.Translations.EditView extends Locomotive.Views.Translations.FormView

  save: (event) ->
    @save_in_ajax event