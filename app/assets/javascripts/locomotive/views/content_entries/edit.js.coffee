Locomotive.Views.ContentEntries ||= {}

class Locomotive.Views.ContentEntries.EditView extends Locomotive.Views.ContentEntries.FormView

  save: (event) ->
    @save_in_ajax event