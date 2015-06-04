Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.EditView extends Locomotive.Views.Shared.FormView

  initialize: ->
    super

    $form = $('form.edit_page')

    $form.on 'ajax:success', (event, data, status, xhr) =>
      $response = $(data)
      window.foo = $response

