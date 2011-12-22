Locomotive.Views.Contents ||= {}

class Locomotive.Views.Contents.EditView extends Locomotive.Views.Contents.FormView

  save: (event) ->
    @save_in_ajax event